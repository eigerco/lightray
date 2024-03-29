# Use golang image as builder
FROM golang:1.21.3 AS go-builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files
COPY go.mod ./
COPY go.sum ./

# Download dependencies
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the Go code to wasm
RUN git submodule update --init --recursive
#RUN cd third_party/celestia-node
#RUN go mod tidy
RUN cd third_party/celestia-node && GOOS=js GOARCH=wasm go build -ldflags="-s -w" --tags "notracing" -o celestia.wasm ./cmd/wasmlight

FROM node AS node-builder

WORKDIR /app

COPY . .

RUN npm run build

# Use nginx as the base image
FROM nginx:latest

# Copy the wasm binary from the builder stage to nginx's html directory
COPY --from=go-builder /app/third_party/celestia-node/celestia.wasm /usr/share/nginx/html/celestia.wasm

COPY --from=node-builder /app/public /usr/share/nginx/html

ARG PUBLIC_BOOTSTRAPER_HOST

RUN echo "window.env = {PUBLIC_BOOTSTRAPER_HOST: '$PUBLIC_BOOTSTRAPER_HOST'}" > /usr/share/nginx/html/env.js

# Expose port 80
EXPOSE 80