module github.com/eigerco/celestia-go-wasm-example

go 1.21.1

toolchain go1.21.3

require go.uber.org/zap v1.26.0

require go.uber.org/multierr v1.10.0 // indirect

replace github.com/celestiaorg/celestia-node => ./third_party/celestia-node
