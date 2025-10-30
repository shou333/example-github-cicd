package main

import "testing"

func TestEvenOrOdd(t *testing.T) {
	tests := []struct {
		name     string
		input    int
		expected string
	}{
		// 偶数テスト
		{"ゼロは偶数です", 0, "even"},
		{"正の偶数", 2, "even"},
		{"正の大きい偶数", 1200, "even"},
		{"負の偶数", -2, "even"},
		{"負の大きい偶数", -100, "even"},
		{"元のテストケース", 10, "even"},

		// 奇数テスト
		{"正の奇数", 1, "odd"},
		{"正の奇数（中）", 3, "odd"},
		{"正の大きい奇数", 2199, "odd"},
		{"負の奇数", -1, "odd"},
		{"負の奇数（中）", -3, "odd"},
		{"負の大きい奇数", -99, "odd"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := EvenOrOdd(tt.input)
			if result != tt.expected {
				t.Errorf("EvenOrOdd(%d): 予期された値は %s ですが、実際は %s でした", tt.input, tt.expected, result)
			}
		})
	}
}
