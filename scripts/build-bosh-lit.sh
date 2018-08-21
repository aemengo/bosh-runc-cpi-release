#!/usr/bin/env bash

set -ex

dir=$(cd `dirname $0` && cd .. && pwd)

linuxkit build \
  -format iso-efi \
  ${dir}/linuxkit/bosh-lit.yml