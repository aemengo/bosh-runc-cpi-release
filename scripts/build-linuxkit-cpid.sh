#!/usr/bin/env bash

set -ex

dir=$(cd `dirname $0` && cd .. && pwd)

export GOPATH=${dir}
export GOOS=linux
export GOARCH=amd64

go build \
  -o $dir/linuxkit/pkg/cpid/cpid \
  github.com/aemengo/bosh-containerd-cpi/cmd/cpid

linuxkit pkg build \
  -force \
  $dir/linuxkit/pkg/cpid
