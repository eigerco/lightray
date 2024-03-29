#!/bin/bash

CELESTIA_NODE_AUTH_TOKEN=$(./celestia light auth admin) ./bootstrapper --config=./bootstrapper-config.json
