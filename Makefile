.PHONY: build-bootstrapper
build-bootstrapper:
	cd third_party/celestia-node && go build -o ./build/bootstrapper ./cmd/bootstrapper

.PHONY: run-bootstrapper
run-bootstrapper: build-bootstrapper
	cd third_party/celestia-node && ./build/bootstrapper --config="../../bootstrapper-config.json"

copy-wasm-exec:
	cp ~/.goenv/versions/1.21.3/misc/wasm/wasm_exec.js public/wasm_exec.js

build-celestia-wasm:
	@echo "Building celestia wasm"
	cd third_party/celestia-node && goenv exec go mod tidy && GOOS=js GOARCH=wasm goenv exec go build -ldflags="-s -w" --tags "notracing" -o ./build/celestia.wasm ./cmd/wasmlight
	cp third_party/celestia-node/build/celestia.wasm public/celestia.wasm

build: build-bootstrapper build-celestia-wasm
	@echo "Build complete"

deploy:
	npm run build
	sudo cp -r public/* /var/www/html/

deploy-bootstrapper: build-bootstrapper
	cp ./third_party/celestia-node/build/bootstrapper /usr/local/bin/bootstrapper