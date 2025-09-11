#!/bin/bash -e

. .env
. common.sh

await_liveness $CONSUMER_LIVENESS
get_access_token
validate_access_token

set +e
ACCESS_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJBdXRobGliIiwic3ViIjoiMTIzIn0.B_zV577ANdMhUXMoFEbLcyVlVX1Nrp-JAW3AL9cqGj7m4JO6ld62VAlDpx9cJG4ZnfKSTkPcDjLAFERvM6Y5W60b5lELo59cL9GI4LB7zplAef8Xsp4I8VkJEGM61hUi73TxrgUi3HHgk14u26wLBkpukycP3_hWaJJlm8zoDC" ### wrong
validate_access_token --xfail
[ "$?" -gt "0" ] || exit 1

ACCESS_TOKEN=""
validate_access_token --xfail
[ "$?" -gt "0" ] || exit 1
set -e

# token service is not publicly available
set +e
TOKEN_SERVICE=${CONSUMER_PUBLIC}/token
get_access_token --xfail
[ "$?" -eq "22" ] || exit 1
log "0" "404 - Not Found"



echo -e "\nOK"
