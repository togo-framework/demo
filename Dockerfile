# Demo app — single container: nginx serves the built dashboard + proxies the API
# to the Go binary; SQLite is embedded (a /data volume).

# --- frontend ---
FROM node:22-alpine AS web
WORKDIR /web
COPY web/package*.json ./
RUN npm ci
COPY web/ ./
RUN npm run build

# --- backend ---
FROM golang:1.26-alpine AS api
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /demo-api ./cmd/api \
 && CGO_ENABLED=0 go build -o /demo-migrate ./cmd/migrate \
 && CGO_ENABLED=0 go build -o /demo-seed ./cmd/seed

# --- runtime ---
FROM nginx:alpine
RUN apk add --no-cache ca-certificates
COPY --from=api /demo-api /demo-migrate /demo-seed /usr/local/bin/
COPY --from=web /web/dist /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY deploy/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV DATABASE_URL="sqlite:///data/demo.db?_pragma=busy_timeout(5000)" \
    ADDR=":8080"
VOLUME /data
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
