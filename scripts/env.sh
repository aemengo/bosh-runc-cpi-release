#!/usr/bin/env bash

export BOSH_ENVIRONMENT="10.0.0.4"
export BOSH_CA_CERT="$(bosh int /tmp/creds.yml --path /director_ssl/ca)"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET="$(bosh int /tmp/creds.yml --path /admin_password)"