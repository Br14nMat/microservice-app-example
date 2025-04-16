FROM golang:1.18-alpine AS builder  

WORKDIR /app

COPY . . 


ENV GO111MODULE=on


RUN go mod init github.com/bortizf/microservice-app-example/tree/master/auth-api && \
    go mod tidy &&\
    go build -o auth-api .


FROM alpine:latest


RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app


COPY --from=builder /app/auth-api .

RUN chown appuser:appgroup /app/auth-api


USER appuser

CMD ["./auth-api"]