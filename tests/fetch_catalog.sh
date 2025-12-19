#/bin/bash
set -e

source ./.env
source ./common.sh

TOKEN_SCOPE=${CONSUMER_TOKEN_SCOPE}
TOKEN_SERVICE=${CONSUMER_TOKEN_SERVICE}
TOKEN_CLIENT_AUTH_HEADER=${CONSUMER_TOKEN_CLIENT_AUTH_HEADER}
get_access_token

fetch_catalog
