#!/usr/bin/env bash

set -e

dir=$(cd `dirname $0` && cd .. && pwd)
export GOPATH=${dir}
export GOARCH=amd64

if [[ -z "${1}" ]]; then
  echo "USAGE: $0 <release-version> <trusty-stemcell-version>"
  exit 1
fi

if [[ -z "${2}" ]]; then
  echo "USAGE: $0 <release-version> <trusty-stemcell-version>"
  exit 1
fi

if ! bosh env >/dev/null 2>&1; then
  echo "Error: you must target a bosh director first for pre-compilation"
  exit 1
fi

version=$1
stemcell_version=$2

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

## Assume that a gcp environment is being used
bosh upload-stemcell https://s3.amazonaws.com/bosh-gce-light-stemcells/light-bosh-stemcell-${stemcell_version}-google-kvm-ubuntu-trusty-go_agent.tgz
bosh create-release --dir=${dir} --name=bosh-runc-cpi-compiled --version=${version} --tarball=${dir}/bosh-runc-cpi-compiled-v${version}.tgz --force
bosh upload-release ${dir}/bosh-runc-cpi-compiled-v${version}.tgz

cat > ${dir}/compilation-workspace.yml <<EOF
name: compilation-workspace

releases:
- name: bosh-runc-cpi-compiled
  version: ${version}

stemcells:
- alias: default
  os: ubuntu-trusty
  version: "${stemcell_version}"

instance_groups: []

update:
  canaries: 1
  max_in_flight: 1
  canary_watch_time: 1000-90000
  update_watch_time: 1000-90000
EOF

bosh -n -d compilation-workspace deploy ${dir}/compilation-workspace.yml
bosh -n -d compilation-workspace export-release bosh-runc-cpi-compiled/${version} ubuntu-trusty/${stemcell_version}
compiled_release=$(ls ${dir}/bosh-runc-cpi-compiled-*-ubuntu-trusty-*.tgz)
sha_compiled=$(shasum -a 1 ${compiled_release} | awk '{print $1}')

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

## runc-cpi-compiled
\`\`\`
- name: "bosh-runc-cpi-compiled"
  version: "${version}"
  url: "https://github.com/aemengo/bosh-runc-cpi-release/releases/download/v${version}/${compiled_release}"
  sha1: "${sha_compiled}"

bosh upload-release --sha1 ${sha_compiled} \\
  https://github.com/aemengo/bosh-runc-cpi-release/releases/download/v${version}/${compiled_release}
\`\`\`

## stemcell
\`\`\`
- alias: "default"
  os: "ubuntu-trusty"
  version: "${stemcell_version}"

bosh upload-stemcell --sha1 <STEMCELL_SHASUM> \\
  https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=${stemcell_version}
\`\`\`
EOF
