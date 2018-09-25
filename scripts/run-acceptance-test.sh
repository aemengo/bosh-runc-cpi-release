#!/usr/bin/env bash

set -e

dir=$(cd `dirname $0` && cd .. && pwd)
bosh_deployment_dir=${dir}/../bosh-deployment
temp_dir="/tmp"
cpi_path=${temp_dir}/cpi.tgz
external_cpid_ip="127.0.0.1"
internal_cpid_ip="192.168.65.3"

rm -f ${temp_dir}/state.json
rm -f ${temp_dir}/creds.yml

echo "-----> `date`: Create dev release"
bosh create-release --force --dir ${dir} --tarball ${cpi_path}

echo "-----> `date`: Create env"
${dir}/scripts/deploy-bosh.sh

source ${dir}/scripts/env.sh

echo "-----> `date`: Turn off resurrection"
bosh update-resurrection off

echo "-----> `date`: Update cloud config"
bosh -n update-cloud-config ${dir}/operations/cloud-config.yml

echo "-----> `date`: Upload stemcell"
bosh -n upload-stemcell "https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v3586.40"

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
${dir}/scripts/destroy-bosh.sh

echo "-----> `date`: Done"