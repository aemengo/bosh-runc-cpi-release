#!/usr/bin/env bash

set -e

dir=$(cd `dirname $0` && cd .. && pwd)
export GOPATH=${dir}
export GOARCH=amd64

if [[ -z "${1}" ]]; then
  echo "USAGE: $0 <release-version>"
  exit 1
fi

version=$1

GOOS=linux go build \
  -o ${dir}/runc-cpi-linux \
  github.com/aemengo/bosh-runc-cpi/cmd/cpi

GOOS=darwin go build \
  -o ${dir}/runc-cpi-darwin \
  github.com/aemengo/bosh-runc-cpi/cmd/cpi

bosh add-blob --dir=${dir} ${dir}/runc-cpi-darwin runc-cpi-darwin
bosh add-blob --dir=${dir} ${dir}/runc-cpi-linux runc-cpi-linux

bosh create-release --dir=${dir} --name=bosh-runc-cpi --version=${version} --tarball=${dir}/bosh-runc-cpi-v${version}.tgz --final --force
sha=$(shasum -a 1 ${dir}/bosh-runc-cpi-v${version}.tgz | awk '{print $1}')

cat <<EOF
## runc-cpi
\`\`\`
- name: "bosh-runc-cpi"
  version: "${version}"
  url: "https://github.com/aemengo/bosh-runc-cpi-release/releases/download/v${version}/bosh-runc-cpi-v${version}.tgz"
  sha1: "${sha}"

bosh upload-release --sha1 ${sha} \\
  https://github.com/aemengo/bosh-runc-cpi-release/releases/download/v${version}/bosh-runc-cpi-v${version}.tgz
\`\`\`
EOF
