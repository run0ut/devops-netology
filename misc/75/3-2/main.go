package main

import "fmt"
import "sort"

func getMin (toSort []int)(minNum int) {
	sort.Ints(toSort)
	minNum = toSort[0]
	return
}

func main() {
	// Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
	x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
	y := getMin(x)
	fmt.Printf("Наименьшее число в списке: %v\n", y)
}