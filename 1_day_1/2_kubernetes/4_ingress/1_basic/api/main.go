package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
)

const (
	port    = ":8080"
	service = "API"
)

// Set the LOG_LEVEL from environment variable
// defaults to INFO if not set
func init() {
	l := os.Getenv("LOG_LEVEL")
	if l == "" {
		logrus.Warnln("no log level set, falling back to INFO")
		logrus.SetLevel(logrus.InfoLevel)
		return
	}
	logLvl, err := logrus.ParseLevel(l)
	if err != nil {
		logrus.Warnf("invalid log level %s, falling back to INFO", logLvl)
		logrus.SetLevel(logrus.InfoLevel)
		return
	}
	logrus.Infof("setting log level to %s", logLvl)
	logrus.SetLevel(logLvl)
}

func main() {
	r := mux.NewRouter()
	r.PathPrefix("/api/").HandlerFunc(handleAPI)
	r.PathPrefix("/healthz/").HandlerFunc(handleHealthz)

	logrus.Infof("serving on %s", port)
	logrus.Fatal(http.ListenAndServe(port, r))
}

func handleAPI(w http.ResponseWriter, r *http.Request) {
	p := r.URL.Path
	msg := fmt.Sprintf("[%s] serving %s\n", service, p)

	logrus.Debugf("[%s] recieved request on %s", service, p)
	logrus.Infof(msg)

	w.Write([]byte(msg))
}

func handleHealthz(w http.ResponseWriter, r *http.Request) {
	p := r.URL.Path
	logrus.Debugf("[%s] received healthcheck on %s", service, p)
	w.WriteHeader(http.StatusOK)
}
