#!/usr/bin/env bash

set -e

dir=$(cd `dirname $0` && cd .. && pwd)
bosh_deployment_dir=${dir}/../bosh-deployment
cf_deployment_dir=${dir}/../cf-deployment
static_ip="10.0.0.5"
temp_dir="/tmp"

export BOSH_ENVIRONMENT="10.0.0.4"
export BOSH_CA_CERT="$(bosh int ${temp_dir}/creds.yml --path /director_ssl/ca)"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int ${temp_dir}/creds.yml --path /admin_password)"

echo "-----> `date`: Update cloud config"
bosh -n update-cloud-config ${dir}/operations/cf/cloud-config.yml \
  -v static_ip=${static_ip}

echo "-----> `date`: Update runtime config"
bosh -n update-runtime-config ${bosh_deployment_dir}/runtime-configs/dns.yml \
  --name dns \
  -v host_ip=192.168.65.1 \
  --vars-store ${temp_dir}/cf_vars.yml

echo "-----> `date`: Deploy cf"
bosh -n deploy -d cf ${cf_deployment_dir}/cf-deployment.yml \
  -o ${cf_deployment_dir}/operations/experimental/disable-consul.yml \
  -o ${cf_deployment_dir}/operations/bosh-lite.yml \
  -o ${cf_deployment_dir}/operations/experimental/disable-consul-bosh-lite.yml \
  -o ${cf_deployment_dir}/operations/experimental/fast-deploy-with-downtime-and-danger.yml \
  -o ${dir}/operations/cf/bosh-lit.yml \
  -v cf_admin_password=admin \
  -v uaa_admin_client_secret=admin-client-secret \
  -v system_domain=dev.cfdev.sh \
  -v static_ip=${static_ip} \
  --vars-store ${temp_dir}/cf_vars.yml \
  --no-redact

echo "-----> `date`: Done"