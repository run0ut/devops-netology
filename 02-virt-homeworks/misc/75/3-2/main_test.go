package main

import "testing"

func TestMain(t *testing.T) {
	var v int
	v = GetMin([]int{112,56,78,90})
	if v != 56 {
		t.Error("Expected 56, got ", v)
	}
}