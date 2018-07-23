package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

type handler struct {
	db *sql.DB
}

func (h handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	err := h.db.Ping()
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}
	hostname, _ := os.Hostname()
	msg := fmt.Sprintf("[%s] pinged db\n", hostname)
	fmt.Print(msg)
	w.Write([]byte(msg))
}

func main() {
	db, err := connect()
	if err != nil {
		panic(err)
	}

	h := handler{db}
	http.ListenAndServe(":8080", h)
}

func connect() (*sql.DB, error) {
	host := os.Getenv("DB_HOST")
	port := os.Getenv("DB_PORT")
	user := os.Getenv("DB_USER")
	password := os.Getenv("DB_PASS")
	dbName := "postgres"

	psqlInfo := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbName,
	)
	fmt.Printf("connecting to %s\n", psqlInfo)
	return sql.Open("postgres", psqlInfo)
}
