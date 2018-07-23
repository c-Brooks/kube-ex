FROM golang

COPY . /go/src/github.com/c-brooks/api
WORKDIR /go/src/github.com/c-brooks/api

RUN go get -v
RUN go build -o api

EXPOSE 8080

CMD [ "./api" ]
