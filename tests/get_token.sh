#!/bin/bash -e

. .env
. common.sh

# check consumer first

TOKEN_SCOPE=${CONSUMER_TOKEN_SCOPE}
TOKEN_SERVICE=${CONSUMER_PUBLIC}/token
TOKEN_CLIENT_AUTH_HEADER=${CONSUMER_TOKEN_CLIENT_AUTH_HEADER}

get_access_token
