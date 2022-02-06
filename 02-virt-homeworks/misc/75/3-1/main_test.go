package main

import "testing"

func TestMain(t *testing.T) {
	var v float64
	v = MtoF(8)
	if v != 26.248 {
		t.Error("Expected 26.248, got ", v)
	}
}