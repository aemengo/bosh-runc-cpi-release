#!/usr/bin/env bash

set -e

dir=$(cd `dirname $0` && cd .. && pwd)
bosh_deployment_dir=${dir}/../bosh-deployment
cf_deployment_dir=${dir}/../cf-deployment
static_ip="10.0.0.5"
temp_dir="/tmp"

# eval "$(blt env)"
source ${dir}/scripts/env.sh

stemcell_version=$(bosh int --path /stemcells/0/version ${cf_deployment_dir}/cf-deployment.yml)
if ! bosh stemcells --json | jq -r .Tables[0].Rows[].version | grep ${stemcell_version} ; then
  bosh -n upload-stemcell "https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-${stemcell_version}-warden-boshlite-ubuntu-trusty-go_agent.tgz"
fi

bosh -n update-cloud-config ${dir}/operations/cf/cloud-config.yml \
  -v static_ip=${static_ip}

bosh -n update-runtime-config ${bosh_deployment_dir}/runtime-configs/dns.yml \
  --name dns \
  -v host_ip=192.168.65.1 \
  --vars-store ${temp_dir}/cf_vars.yml

bosh -n deploy -d cf ${cf_deployment_dir}/cf-deployment.yml \
  -o ${cf_deployment_dir}/operations/use-compiled-releases.yml \
  -o ${cf_deployment_dir}/operations/experimental/disable-consul.yml \
  -o ${cf_deployment_dir}/operations/bosh-lite.yml \
  -o ${cf_deployment_dir}/operations/experimental/disable-consul-bosh-lite.yml \
  -o ${cf_deployment_dir}/operations/experimental/fast-deploy-with-downtime-and-danger.yml \
  -o ${dir}/operations/cf/bosh-lit.yml \
  -v cf_admin_password=admin \
  -v uaa_admin_client_secret=admin-client-secret \
  -v system_domain=dev.cfdev.sh \
  -v static_ip=${static_ip} \
  --vars-store ${temp_dir}/cf_vars.yml
