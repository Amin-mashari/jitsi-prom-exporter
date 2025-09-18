# ---- Build stage ----
FROM golang:1.25.1-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

# Copy source code
COPY exporter/ .

# Initialize go.mod if it doesn't exist and fetch dependencies
RUN [ ! -f go.mod ] && go mod init jitsi-prom-exporter || true
RUN go mod tidy

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /jitsi-prom-exporter .

# ---- Runtime stage ----
FROM alpine:latest

RUN adduser -D prom
COPY --from=builder /jitsi-prom-exporter /usr/local/bin/exporter
RUN chmod ugo+x /usr/local/bin/exporter

USER prom
EXPOSE 8090
CMD ["exporter"]
