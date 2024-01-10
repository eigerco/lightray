.PHONY: build-client
build-client:
	go mod tidy
	cd go/client && GOOS=js GOARCH=wasm go build -o main.wasm && cp main.wasm ../../public/main.wasm

build-client-standard:
	go mod tidy
	cd go/client && goenv exec go build

.PHONY: build-server
build-server:
	go mod tidy
	cd go/server && go build -o ../../bin/server

.PHONY: run-server
run-server: build-server
	./bin/server &

copy-wasm-exec:
	cp /Users/nevio/.goenv/versions/1.21.3/misc/wasm/wasm_exec.js public/wasm_exec.js

build-celestia-wasm:
	@echo "Building celestia wasm"
	cd third_party/celestia-node && goenv exec go mod tidy && GOOS=js GOARCH=wasm goenv exec go build --tags "light notracing nometrics" -o ./build/celestia.wasm ./cmd/wasmlight
	cp third_party/celestia-node/build/celestia.wasm public/celestia.wasm

build: build-client build-server build-celestia-wasm
	@echo "Build complete"

.PHONY: watch
watch:
	npx concurrently "air"

.PHONY: dev
dev:
	npx concurrently "make watch"
