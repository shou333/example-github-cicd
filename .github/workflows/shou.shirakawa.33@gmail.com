name: Multi-line Environment Variable Issue Demo

on: workflow_dispatch

jobs:
  extract-content:
    runs-on: ubuntu-latest
    outputs:
      content: ${{ steps.extract.outputs.content }}
    steps:
      - name: Extract multi-line content
        id: extract
        run: |
          # Simulate extracting multi-line content (like DDL extraction)
          CONTENT="CREATE TABLE user (
            id BIGINT NOT NULL,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL,
            PRIMARY KEY (id)
          );
          CREATE TABLE order_table (
            order_id BIGINT NOT NULL,
            user_id BIGINT NOT NULL,
            amount DECIMAL(10, 2),
            created_at TIMESTAMP,
            PRIMARY KEY (order_id),
            FOREIGN KEY (user_id) REFERENCES user (id)
          );"

          # Output using heredoc (GitHub Actions format)
          echo "content<<EOF" >> $GITHUB_OUTPUT
          echo "$CONTENT" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

  demonstrate-issue:
    needs: extract-content
    if: needs.extract-content.outputs.content != null
    runs-on: ubuntu-latest

    steps:
      - name: Problem - Using environment variable (will fail)
        env:
          content: ${{ needs.extract-content.outputs.content }}
        run: |
          echo "=== Attempting to use environment variable ==="
          echo "${{ env.content }}" > content.txt
          echo "Result: File created (but with potential parsing issues)"
          echo ""
          echo "If bash tries to interpret the content as commands, we'd see:"
          echo "  command not found: user"
          echo "  command not found: order_table"
          echo ""
          cat content.txt
          rm -f content.txt

      - name: Solution - Using heredoc (works correctly)
        run: |
          echo "=== Using heredoc approach ==="
          cat << 'EOF' > content.txt
          ${{ needs.extract-content.outputs.content }}
          EOF
          echo "Result: File created successfully with heredoc"
          echo ""
          echo "Content of file:"
          cat content.txt
          echo ""
          echo "✓ No parsing errors!"
          rm -f content.txt

      - name: Detailed comparison
        run: |
          echo "=== Detailed Comparison ==="
          echo ""
          echo "Problem Approach:"
          echo "  env:"
          echo "    content: \${{ needs.extract-content.outputs.content }}"
          echo "  run: |"
          echo "    echo \"\${{ env.content }}\" > file.txt"
          echo ""
          echo "Issues:"
          echo "  ❌ Multi-line content can be incorrectly parsed"
          echo "  ❌ Table/column names may be interpreted as shell commands"
          echo "  ❌ Can cause 'command not found' errors"
          echo ""
          echo "---"
          echo ""
          echo "Solution Approach:"
          echo "  run: |"
          echo "    cat << 'EOF' > file.txt"
          echo "    \${{ needs.extract-content.outputs.content }}"
          echo "    EOF"
          echo ""
          echo "Benefits:"
          echo "  ✅ Content passed directly to cat via heredoc"
          echo "  ✅ No bash variable expansion issues"
          echo "  ✅ Preserves exact content, including special characters"
          echo "  ✅ Safe for any multi-line content"

      - name: Advanced - Demonstration with tricky content
        run: |
          echo "=== Handling Tricky Content ==="
          echo ""

          # Demonstrate with content that includes special characters
          cat << 'EOF' > result.txt
          CREATE TABLE special_table (
            id BIGINT NOT NULL,
            data VARCHAR(255) NOT NULL COMMENT 'Contains $dollar and $(command)',
            amount DECIMAL(10, 2) DEFAULT 0.00,
            tags JSON,
            PRIMARY KEY (id)
          );
          EOF

          echo "Successfully handled content with:"
          echo "  - Dollar signs ($)"
          echo "  - Command substitution syntax \$()"
          echo "  - Special characters"
          echo ""
          echo "Content:"
          cat result.txt
          rm -f result.txt
