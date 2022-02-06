package main

import "fmt"

func MtoF(m float64)(f float64) {
    f = m * 3.281
    return
}

func main() {
    // Напишите программу для перевода метров в футы (1 фут = 0.3048 метр).
    // Можно запросить исходные данные у пользователя, а можно статически задать в коде.
    fmt.Print("Введите длину в метрах (для перевода в футы): ")
    var input float64
    fmt.Scanf("%f", &input)

    output := MtoF(input)

    fmt.Printf("В метрах %v, а в футах это %v\n", input, output)
}