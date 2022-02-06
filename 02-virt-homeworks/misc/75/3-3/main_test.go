package main

import "fmt"
import "testing"

func TestMain(t *testing.T) {
	var v []int
	v = FilterList()
	if v[4] != 15 || v[18] != 57 {
		s := fmt.Sprintf("Expected values 15 and 57, got %v and %v", v[4], v[18])
		t.Error(s)
	}
}