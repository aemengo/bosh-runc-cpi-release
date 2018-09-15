#!/usr/bin/env bash

set -e

dir=$(cd `dirname $0` && cd .. && pwd)
bosh_deployment_dir=${dir}/../bosh-deployment
external_cpid_ip="127.0.0.1"
internal_cpid_ip="192.168.65.3"
temp_dir="/tmp"

bosh create-env ${bosh_deployment_dir}/bosh.yml \
  -o ${dir}/operations/runc-cpi.yml \
  --state ${temp_dir}/state.json \
  --vars-store ${temp_dir}/creds.yml \
  -v director_name=director \
  -v external_cpid_ip=${external_cpid_ip} \
  -v internal_cpid_ip=${internal_cpid_ip} \
  -v internal_ip=10.0.0.4 \
  -v internal_gw=10.0.0.1 \
  -v internal_cidr=10.0.0.0/16