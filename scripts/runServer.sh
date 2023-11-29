#!/bin/bash

# Start Go server in the background
./bin/server & SERVER_PID=$!

# Start Node.js server
npm run dev

# Stop Go server when exiting
kill $SERVER_PID
