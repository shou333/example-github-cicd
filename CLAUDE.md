# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a sample code repository accompanying the GitHub CI/CD practical guide book (「GitHub CI/CD実践ガイド」). It provides examples of GitHub Actions workflows, custom actions, Docker configurations, and Go code across multiple chapters (Chapters 2-17 of the book).

## Repository Structure

- **`.github/workflows/`** - GitHub Actions workflow files demonstrating various CI/CD patterns and concepts (organized by chapter)
- **`.github/actions/`** - Custom composite actions (dump, hello, container-build, container-deploy)
- **`.github/scripts/`** - Utility scripts used by workflows (bump.sh, token.sh)
- **`go/`** - Go source code examples:
  - `go/excellent/` - Main example package with tests
  - `go/example/` - Additional example package
- **`docker/`** - Docker configuration examples:
  - `docker/example/` - Basic example Dockerfile
  - `docker/ecs/` - ECS deployment Dockerfile
- **`command/`** - Copy-paste command examples from chapters 11-12
- **`policy/`** - Conftest policy files (workflow.rego)
- **`action.yml`** - Root-level GitHub Action that creates PRs

## Common Development Tasks

### Testing Go Code
```bash
# Run all tests in the excellent package
go test go/excellent/*.go

# Run tests for a single file
go test go/excellent/main_test.go

# Run with verbose output
go test -v go/excellent/*.go
```

The Go version is pinned to 1.22 in `.go-version`.

### Workflows

**Triggering Workflows:**
- Most workflows are defined in `.github/workflows/` and demonstrate specific GitHub Actions concepts
- Workflows can be triggered manually (workflow_dispatch), on pull requests, on schedule, or on push events
- The test workflow (test.yml) only runs on PRs that modify files in `go/**/*.go`

**Key Workflow Examples:**
- `test.yml` - Runs Go tests on PR creation (filtered by Go file changes)
- `publish.yml` - Publishes Docker images to GitHub Container Registry (ghcr.io)
- `static-analysis.yml` - Performs static analysis checks
- `release.yml` - Creates releases and handles versioning
- `conftest.yml` - Runs Conftest policy validation against workflows

### Custom Actions

All custom actions are composite actions (shell-based):
- Located in `.github/actions/`
- Use `shell: bash` with `run:` sections
- Export outputs via `$GITHUB_OUTPUT`

**Root Action (action.yml):**
- Creates pull requests from workflow changes
- Requires `contents: write` and `pull-requests: write` permissions
- Takes message input and outputs branch name

### Docker Image Publishing

The publish workflow (publish.yml):
- Builds Docker images from directories under `docker/example/`
- Pushes to GitHub Container Registry (ghcr.io)
- Uses semantic versioning tags
- Requires `packages: write` and `contents: read` permissions

## Important Notes

- This repository is primarily for **educational and reference purposes**, containing examples from a GitHub Actions book
- Workflows demonstrate specific patterns and concepts - not all are meant to be production-ready
- Some workflows intentionally contain errors or edge cases for teaching purposes
- Chapter references in filenames (e.g., コード2.1, コード3.1) correspond to book code listings
- Environment setup uses GitHub's standard setup actions (setup-go, etc.)
