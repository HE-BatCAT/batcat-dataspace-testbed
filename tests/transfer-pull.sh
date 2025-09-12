#/bin/bash
set -e

source ./.env
source ./common.sh

await_liveness $PROVIDER_LIVENESS
await_liveness $CONSUMER_LIVENESS


# provider
TOKEN_SCOPE=${PROVIDER_TOKEN_SCOPE}
TOKEN_SERVICE=${PROVIDER_TOKEN_SERVICE}
TOKEN_CLIENT_AUTH_HEADER=${PROVIDER_TOKEN_CLIENT_AUTH_HEADER}
get_access_token

create_asset
create_policy
create_contract_def


# consumer
TOKEN_SCOPE=${CONSUMER_TOKEN_SCOPE}
TOKEN_SERVICE=${CONSUMER_TOKEN_SERVICE}
TOKEN_CLIENT_AUTH_HEADER=${CONSUMER_TOKEN_CLIENT_AUTH_HEADER}
get_access_token

fetch_catalog
get_data_set
negotiate_contract
get_contract_agreement

start_transfer_pull
check_transfer "STARTED"

RESPONSE="$(curl $CURL_OPTS \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    $CONSUMER_MANAGEMENT/v3/edrs/$TRANSFER_PROCESS_ID/dataaddress)"
echo "$RESPONSE" | jq
echo "$RESPONSE" | jq '.authType'
echo "$RESPONSE" | jq '.authorization'

ENDPOINT="$(echo "$RESPONSE" | jq --raw-output '.endpoint')"
DOWNLOAD_ACCESS_TOKEN="$(echo "$RESPONSE" | jq --raw-output '.authorization')"
echo "Endpoint: $ENDPOINT"

curl $CURL_OPTS -v "$ENDPOINT" \
    -H "Authorization: $DOWNLOAD_ACCESS_TOKEN"



echo -e "\nOK"
