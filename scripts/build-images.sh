#!/usr/bin/env bash

set -ex

dir=$(cd `dirname $0` && cd .. && pwd)
export GOPATH=${dir}
export GOOS=linux
export GOARCH=amd64

# build vpnkit-manager
go build \
  -o ${dir}/linuxkit/pkg/vpnkit-manager/vpnkit-manager \
  github.com/aemengo/vpnkit-manager

sha=$(git -C $dir/src/github.com/aemengo/vpnkit-manager rev-parse HEAD)
echo ${sha} > ${dir}/linuxkit/pkg/vpnkit-manager/sha

# build cpid
go build \
  -o ${dir}/linuxkit/pkg/runc-cpid/cpid \
  github.com/aemengo/bosh-runc-cpi/cmd/cpid

sha=$(git -C $dir/src/github.com/aemengo/bosh-runc-cpi rev-parse HEAD)
echo ${sha} > ${dir}/linuxkit/pkg/runc-cpid/sha

# build container images
linuxkit pkg build \
  -force \
  ${dir}/linuxkit/pkg/vpnkit-manager

linuxkit pkg build \
  -force \
  ${dir}/linuxkit/pkg/runc-cpid