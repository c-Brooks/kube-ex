FROM golang:1.11beta1-stretch as builder

COPY . /go/src/github.com/c-brooks/echo-hostname
WORKDIR /go/src/github.com/c-brooks/echo-hostname

RUN go get -v
RUN CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags '-s' -o app

FROM scratch

COPY --from=builder /go/src/github.com/c-Brooks/echo-hostname/app /usr/bin/app

CMD [ "/usr/bin/app" ]

EXPOSE 80

