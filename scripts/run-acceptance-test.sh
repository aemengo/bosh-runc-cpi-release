#!/usr/bin/env bash

set -e

dir=$(cd `dirname $0` && cd .. && pwd)
bosh_deployment_dir=${dir}/../bosh-deployment
temp_dir="/tmp"
cpi_path=${temp_dir}/cpi.tgz
static_ip="192.168.64.8"

rm -f ${temp_dir}/state.json
rm -f ${temp_dir}/creds.yml

echo "-----> `date`: Create dev release"
bosh create-release --force --dir ${dir} --tarball ${cpi_path}

echo "-----> `date`: Create env"
bosh create-env ${bosh_deployment_dir}/bosh.yml \
  -o ${dir}/operations/runc-cpi.yml \
  --state ${temp_dir}/state.json \
  --vars-store ${temp_dir}/creds.yml \
  -v director_name=director \
  -v static_ip=${static_ip} \
  -v internal_ip=10.0.0.4 \
  -v internal_gw=10.0.0.1 \
  -v internal_cidr=10.0.0.0/16

export BOSH_ENVIRONMENT=${static_ip}
export BOSH_CA_CERT="$(bosh int ${temp_dir}/creds.yml --path /director_ssl/ca)"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int ${temp_dir}/creds.yml --path /admin_password)"

echo "-----> `date`: Update cloud config"
bosh -n update-cloud-config ${dir}/operations/cloud-config.yml

echo "-----> `date`: Upload stemcell"
bosh -n upload-stemcell "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v3586.25" \
  --sha1 2236969026e22a50151a287a297b35a15619d01c

echo "-----> `date`: Delete previous deployment"
bosh -n -d zookeeper delete-deployment --force

echo "-----> `date`: Deploy"
bosh -n -d zookeeper deploy <(curl -s https://raw.githubusercontent.com/cppforlife/zookeeper-release/master/manifests/zookeeper.yml)

echo "-----> `date`: Recreate all VMs"
bosh -n -d zookeeper recreate

echo "-----> `date`: Exercise deployment"
bosh -n -d zookeeper run-errand smoke-tests

echo "-----> `date`: Restart deployment"
bosh -n -d zookeeper restart

echo "-----> `date`: Report any problems"
bosh -n -d zookeeper cck --report

echo "-----> `date`: Delete random VM"
bosh -n -d zookeeper delete-vm `bosh -d zookeeper vms|sort|cut -f5|head -1`

echo "-----> `date`: Fix deleted VM"
bosh -n -d zookeeper cck --auto

echo "-----> `date`: Delete deployment"
bosh -n -d zookeeper delete-deployment

echo "-----> `date`: Clean up disks, etc."
bosh -n -d zookeeper clean-up --all

echo "-----> `date`: Deleting env"
bosh delete-env ${bosh_deployment_dir}/bosh.yml \
  -o ${dir}/operations/runc-cpi.yml \
  --state ${temp_dir}/state.json \
  --vars-store ${temp_dir}/creds.yml \
  -v director_name=director \
  -v static_ip=${static_ip} \
  -v internal_ip=10.0.0.4 \
  -v internal_gw=10.0.0.1 \
  -v internal_cidr=10.0.0.0/16

echo "-----> `date`: Done"
