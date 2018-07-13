#!/usr/bin/env bash

set -ex

dir=$(cd `dirname $0` && cd .. && pwd)

export GOPATH=${dir}
export GOOS=linux
export GOARCH=amd64

go build \
  github.com/aemengo/bosh-runc-cpi/cmd/cpid