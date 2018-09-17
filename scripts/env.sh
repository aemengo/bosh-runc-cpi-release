#!/usr/bin/env bash

export BOSH_ENVIRONMENT="10.0.0.4"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int /tmp/creds.yml --path /admin_password)"

bosh int /tmp/creds.yml --path /director_ssl/ca > /tmp/bosh-ca-cert
export BOSH_CA_CERT=/tmp/bosh-ca-cert

export BOSH_GW_HOST="10.0.0.4"
export BOSH_GW_USER="jumpbox"

bosh int /tmp/creds.yml --path /jumpbox_ssh/private_key > /tmp/bosh-gw-private-key
chmod 0600 /tmp/bosh-gw-private-key
export BOSH_GW_PRIVATE_KEY=/tmp/bosh-gw-private-key
