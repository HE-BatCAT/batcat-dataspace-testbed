#/bin/bash
set -e

source ./.env
source ./common.sh

await_liveness $PROVIDER_LIVENESS
await_liveness $CONSUMER_LIVENESS
create_asset
create_policy
create_contract_def

get_access_token
fetch_catalog
get_data_set
negotiate_contract
get_contract_agreement

create_upload_destination
start_transfer_push
check_transfer

echo -e "\nOK"
