package main

import (
	"os"
	"io/ioutil"
	"log"
	"strings"
	"github.com/progrium/go-basher"
)

func check(args []string) {
	bytes, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		log.Fatal(err)
	}
	runes := []rune(strings.Trim(string(bytes), "\n"))
	for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
		runes[i], runes[j] = runes[j], runes[i]
	}
	println(string(runes))
}

func main() {
	basher.Application(
		map[string]func([]string){
			"check": check,
		}, []string{
			"check.sh",
		},
		Asset,
		true,
	)
}
