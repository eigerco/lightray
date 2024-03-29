FROM golang:1.22.0 AS celestia-builder

WORKDIR /app

RUN git clone https://github.com/celestiaorg/celestia-node.git
RUN cd celestia-node && make build

# Use golang image as builder
FROM golang:1.21.3 AS builder

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
RUN cd third_party/celestia-node && go build -o bootstrapper ./cmd/bootstrapper

# Use nginx as the base image
FROM ubuntu:22.04

#RUN apt update && apt -y install wget gpg
#RUN apt update && apt -y install git make

WORKDIR /app

# Copy the wasm binary from the builder stage to nginx's html directory
COPY --from=builder /app/third_party/celestia-node/bootstrapper /app/bootstrapper
COPY --from=builder /app/docker/run-bootstrapper.sh /app/run-bootstrapper.sh
COPY --from=celestia-builder /app/celestia-node/build/celestia /app/celestia

RUN chmod +x ./run-bootstrapper.sh

# Expose port 80
EXPOSE 80

CMD ["./run-bootstrapper.sh"]
