package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

type handler struct{}

func (h handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	hostname, err := os.Hostname()
	if err != nil {
		w.WriteHeader(500)
		return
	}

	fmt.Printf("hello from %s\n", hostname)
	rsp := fmt.Sprintf("Hello from %s\n", hostname)
	w.Write([]byte(rsp))
}

func main() {
	port := ":8080"

	fmt.Printf("serving on %s", port)
	log.Fatal(http.ListenAndServe(port, handler{}))
}
