package main

import (
	"fmt"
	"os"
	"strconv"
)

// elixir is too hard, go does not work for part2, cba figuring it out it's not fun anymore
func main() {
	line, _ := os.ReadFile("input.txt")
	res_1 := Task1(string(line[:]))
	res_2 := Task2(string(line[:]))
	fmt.Printf("RESULT 1: %d, RESULT 2: %d\n", res_1, res_2)
}

func Task1(input string) int {
	diskOrder := createDisk(input)
	orderDisk(&diskOrder)
	result := 0
	index := 0
	for diskOrder[index] != -1 {
		result += index * diskOrder[index]
		index++
	}
	return result
}

func Task2(input string) int {
	diskOrder := createDisk(input)
	orderFiles(&diskOrder)
	result := 0
	for i := 0; i < len(diskOrder); i++ {
		if diskOrder[i] > -1 {
			result += i * diskOrder[i]
		}
	}
	return result
}

func createDisk(line string) []int {
	var resArray []int
	id := 0
	isFree := false
	for _, char := range line {
		numOfElements, _ := strconv.Atoi(string(char))
		for range numOfElements {
			if isFree {
				resArray = append(resArray, -1)
			} else {
				resArray = append(resArray, id)
			}
		}
		if !isFree {
			id++
		}
		isFree = !isFree
	}
	return resArray
}

func orderDisk(disk *[]int) {
	lastIndex := findLastId(disk)
	for i := 0; i < lastIndex; i++ {
		if (*disk)[i] == -1 {
			(*disk)[i] = (*disk)[lastIndex]
			(*disk)[lastIndex] = -1
			lastIndex = findLastId(disk)
		}
	}
}

func findLastId(disk *[]int) int {
	for i := len(*disk) - 1; i >= 0; i-- {
		if (*disk)[i] != -1 {
			return i
		}
	}
	return -1
}

func orderFiles(disk *[]int) {
	fileId := (*disk)[len(*disk)-1]
	for fileId > 0 {
		length := determineIdLen(fileId, disk)
		idIndex := findStartIndex(fileId, disk)
		freeIndex := findFreeIndex(length, idIndex, disk)
		if freeIndex > -1 {
			for offset := range length {
				(*disk)[freeIndex+offset] = (*disk)[idIndex+offset]
				(*disk)[idIndex+offset] = -1
			}
		}
		fileId--
	}
}

func determineIdLen(id int, disk *[]int) int {
	length := 0
	for i := 0; i < len(*disk); i++ {
		if (*disk)[i] == id {
			length++
		}
	}
	return length
}

func findStartIndex(id int, disk *[]int) int {
	for i := 0; i < len(*disk); i++ {
		if (*disk)[i] == id {
			return i
		}
	}
	return -1
}

func findFreeIndex(length int, maxId int, disk *[]int) int {
	startIndex := 0
	runningSpace := false
	actLen := 0
	for i := 0; i < len(*disk) && i < maxId; i++ {
		actInt := (*disk)[i]
		if actInt != -1 {
			runningSpace = false
			actLen = 0
		} else if runningSpace {
			actLen++
			if actLen == length {
				return startIndex
			}
		} else {
			startIndex = i
			actLen++
			runningSpace = true
			if actLen == length {
				return startIndex
			}
		}
	}
	return -1
}
