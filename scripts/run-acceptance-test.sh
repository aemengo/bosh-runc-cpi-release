#!/usr/bin/env bash

set -ex

dir=$(cd `dirname $0` && cd .. && pwd)
bosh_deployment_dir=${dir}/../bosh-deployment
cpi_path=${dir}/cpi.tgz

bosh create-release --force --dir ${dir} --tarball ${cpi_path}

bosh create-env ${bosh_deployment_dir}/bosh.yml \
  -o ${dir}/operations/linuxkit-cpi.yml \
  --state ${dir}/state.json \
  --vars-store ${dir}/creds.yml \
  -v director_name=director \
  -v internal_ip=192.168.50.16 \
  -v internal_gw=192.168.50.1 \
  -v internal_cidr=192.168.50.0/24 \
  -v outbound_network_name=NatNetwork
