#!/usr/bin/env bash

set -ex

dir=$(cd `dirname $0` && cd .. && pwd)
sha=$(git -C $dir/src/github.com/aemengo/bosh-runc-cpi rev-parse HEAD)

${dir}/scripts/build-cpid.sh

mv ./cpid ${dir}/linuxkit/pkg/runc-cpid/cpid
echo ${sha} > ${dir}/linuxkit/pkg/runc-cpid/sha

linuxkit pkg build \
  -force \
  ${dir}/linuxkit/pkg/iptables

linuxkit pkg build \
  -force \
  ${dir}/linuxkit/pkg/tar

linuxkit pkg build \
  -force \
  ${dir}/linuxkit/pkg/criu

linuxkit pkg build \
  -force \
  ${dir}/linuxkit/pkg/runc-cpid