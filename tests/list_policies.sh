#/bin/bash
set -e

source ./.env
source ./common.sh

TOKEN_SCOPE=${PROVIDER_TOKEN_SCOPE}
TOKEN_SERVICE=${PROVIDER_TOKEN_SERVICE}
TOKEN_CLIENT_AUTH_HEADER=${PROVIDER_TOKEN_CLIENT_AUTH_HEADER}
get_access_token

list_policies
