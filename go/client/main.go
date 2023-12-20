package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/signal"
	"syscall"

	libp2p "github.com/libp2p/go-libp2p"
	"github.com/libp2p/go-libp2p/core/network"
)

func main() {
	// Initialize libp2p host
	h, err := libp2p.New()
	if err != nil {
		panic(err)
	}
	defer h.Close()

	// Set a stream handler on the host
	h.SetStreamHandler("/chat/1.0.0", handleStream)

	// Print the host's listening addresses
	fmt.Println("Listening on:")
	for _, addr := range h.Addrs() {
		fmt.Printf("- %s/p2p/%s\n", addr, h.ID())
	}

	// Wait for a signal to exit
	waitExit()
}

func handleStream(s network.Stream) {
	fmt.Println("New stream opened")

	// Create a buffer to read data from the stream
	reader := bufio.NewReader(s)
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			if err != io.EOF {
				fmt.Println("Error reading from buffer:", err)
			}
			break
		}
		fmt.Printf("Received message: %s", line)
	}
	fmt.Println("Stream closed")
}

func waitExit() {
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
	<-ch
	fmt.Println("Received signal, shutting down...")
}
