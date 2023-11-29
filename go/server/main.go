package main

import (
	"net/http"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func main() {
	config := zap.NewDevelopmentConfig()
	config.Level = zap.NewAtomicLevelAt(zap.InfoLevel)
	config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
	logger, _ := config.Build()
	zap.ReplaceGlobals(logger)

	zap.L().Info("Starting server on http://localhost:8090")

	http.Handle("/", http.FileServer(http.Dir("public")))
	http.ListenAndServe(":8090", nil)
}
