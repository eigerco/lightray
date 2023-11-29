package main

import (
	"context"
	"fmt"
	"syscall/js"

	"github.com/libp2p/go-libp2p"
	peer "github.com/libp2p/go-libp2p-core/peer"
	"github.com/libp2p/go-libp2p/core/peerstore"
)

const chatProtocol = "/chat/1.0.0"

func main() {
	g := js.Global()
	document := g.Get("document")
	wasmLogs := document.Call("getElementById", "wasm_logs")

	appendLog := func(msg string, args ...any) {
		msg = fmt.Sprintf(msg, args...)
		// Create a new text node with the log message
		text := document.Call("createTextNode", msg+"\n")
		// Append the text node to the log element
		wasmLogs.Call("appendChild", text)
	}

	h, err := libp2p.New()
	if err != nil {
		appendLog("Error starting libp2p, check the console !")
		panic(err)
	}

	peerID := h.ID()
	appendLog("Starting up webassembly client...")
	appendLog("Peer ID: %s", peerID.String())

	info, err := peer.AddrInfoFromString("/ip4/94.253.197.203/tcp/47471/p2p/12D3KooWD8f4rGREusTmp3UDPhNGCNMb8EaGfQo6sZ9X8fW98LYc")
	if err != nil {
		appendLog("<strong>Error</strong>: %s", err)
	}

	h.Peerstore().AddAddrs(info.ID, info.Addrs, peerstore.PermanentAddrTTL)

	for _, addr := range info.Addrs {
		appendLog("Listener Address: %s/p2p/%s", addr, peer.Encode(h.ID()))
	}

	s, err := h.NewStream(context.Background(), info.ID, chatProtocol)
	if err != nil {
		appendLog("<strong>Stream Error</strong>: %s", err)
	}

	_ = s

	select {}
}
