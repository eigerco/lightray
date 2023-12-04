package main

import (
	"fmt"
	"syscall/js"

	"github.com/libp2p/go-libp2p"
	peer "github.com/libp2p/go-libp2p-core/peer"
	"github.com/libp2p/go-libp2p/core/peerstore"
)

const chatProtocol = "/chat/1.0.0"

func main() {
	appendLog := js.Global().Get("appendLog")

	// Define a Go function that uses appendLog
	log := func(msg string, level string) {
		appendLog.Invoke(msg, level)
	}

	h, err := libp2p.New()
	if err != nil {
		log(fmt.Sprintf("Failed to start libp2p: %s", err), "error")
		panic(err)
	}

	peerID := h.ID()
	log("Starting up webassembly client...", "info")
	log(fmt.Sprintf("Peer ID: %s", peerID.String()), "info")

	info, err := peer.AddrInfoFromString("/ip4/94.253.197.203/tcp/47471/p2p/12D3KooWD8f4rGREusTmp3UDPhNGCNMb8EaGfQo6sZ9X8fW98LYc")
	if err != nil {
		log(fmt.Sprintf("Failed to get address info: %s", err), "error")
		panic(err)
	}

	h.Peerstore().AddAddrs(info.ID, info.Addrs, peerstore.PermanentAddrTTL)

	for _, addr := range info.Addrs {
		log(fmt.Sprintf("Listener Address: %s/p2p/%s", addr, peer.Encode(h.ID())), "info")
	}

	select {}
}
