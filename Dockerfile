FROM golang:1.20 as builder

WORKDIR /go/src/app 
COPY . .
RUN make build

FROM scratch
LABEL org.opencontainers.image.source https://github.com/gitgav/korchi265bot
WORKDIR /
COPY --from=builder /go/src/app/korchi265bot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./korchi265bot", "start"]