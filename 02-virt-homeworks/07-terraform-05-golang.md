devops-netology
===============

# Домашнее задание к занятию "7.5. Основы golang"

<details><summary>.</summary>

> С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
> Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).

</details>  

## Задача 1. Установите golang.

<details><summary>.</summary>

> 1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
> 2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

</details>

```bash
23:11:01 ~ sergey@Netangels-CSVM:~
$ go version
go version go1.17.6 linux/amd64
```

## Задача 2. Знакомство с gotour.

Прошел `Basics`. `Methods and interfaces` и `Concurrency` не изучал.

<details><summary>.</summary>

> У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
> Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

</details>

## Задача 3. Написание кода. 

<details><summary>.</summary>

> Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).
> 
> 1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
> у пользователя, а можно статически задать в коде.
>     Для взаимодействия с пользователем можно использовать функцию `Scanf`:
>     ```
>     package main
>     
>     import "fmt"
>     
>     func main() {
>         fmt.Print("Enter a number: ")
>         var input float64
>         fmt.Scanf("%f", &input)
>     
>         output := input * 2
>     
>         fmt.Println(output)    
>     }
>     ```
>  
> 1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
>     ```
>     x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
>     ```
> 1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.
> 
> В виде решения ссылку на код или сам код. 

</details>

### Напишите программу для перевода метров в футы

```go
package main

import "fmt"

func MtoF(m float64)(f float64) {
    f = m * 3.281
    return
}

func main() {
    fmt.Print("Введите длину в метрах (для перевода в футы): ")
    var input float64
    fmt.Scanf("%f", &input)

    output := MtoF(input)

    fmt.Printf("В метрах %v, а в футах это %v\n", input, output)
}
```

### Напишите программу, которая найдет наименьший элемент в любом заданном списке

```go
package main

import "fmt"
import "sort"

func GetMin (toSort []int)(minNum int) {
	sort.Ints(toSort)
	minNum = toSort[0]
	return
}

func main() {
	x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
	y := GetMin(x)
	fmt.Printf("Наименьшее число в списке: %v\n", y)
}
```

### Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3

```go
package main

import "fmt"

func FilterList ()(devidedWithNoReminder []int) {
	for i := 1;  i <= 100; i ++ {
		if	i % 3 == 0 { 
			devidedWithNoReminder = append(devidedWithNoReminder, i)
		}
	}	
	return
}

func main() {
	toPrint := FilterList()
	fmt.Printf("Числа от 1 до 100, которые делятся на 3 без остатка: %v\n", toPrint)
}
```

## Задача 4. Протестировать код (не обязательно).

<details><summary>.</summary>

> Создайте тесты для функций из предыдущего задания. 

</details>

### Тест для программы, переводящей метры в футы

```go
package main

import "testing"

func TestMain(t *testing.T) {
	var v float64
	v = MtoF(8)
	if v != 26.248 {
		t.Error("Expected 26.248, got ", v)
	}
}
```

### Тест для программы поиска минимального числа из списка

```go
package main

import "testing"

func TestMain(t *testing.T) {
	var v int
	v = GetMin([]int{112,56,78,90})
	if v != 56 {
		t.Error("Expected 56, got ", v)
	}
}
```

### Тест для программы поиска чисел, делимых на три, в диапазоне от 1 до 100

```go
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
```

