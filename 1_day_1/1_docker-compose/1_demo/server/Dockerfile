FROM golang

COPY . /go/src/github.com/c-brooks/pg-ping
WORKDIR /go/src/github.com/c-brooks/pg-ping

RUN go get -v
RUN go build -o pg-ping

EXPOSE 8080

CMD [ "./pg-ping" ]
