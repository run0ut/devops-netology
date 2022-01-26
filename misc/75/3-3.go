package main

import "fmt"

func main() {
	// Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть (3, 6, 9, …).
	var devidedWithNoReminder []int
	for i := 1;  i <= 100; i ++ {
		if	i % 3 == 0 { 
			devidedWithNoReminder = append(devidedWithNoReminder, i)
		}
	}
	fmt.Printf("Числа от 1 до 100, которые делятся на 3 без остатка: %v\n", devidedWithNoReminder)
}