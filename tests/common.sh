shopt -s inherit_errexit
CURL_OPTS="-s --fail-with-body"
VERBOSE="${VERBOSE:-0}"


log () {
    trap "$(shopt -p -o errexit)" RETURN
    code="$1"
    level=$((VERBOSE + code))
    if [ "$level" -gt "0" ] ; then
        shift
        set +e
        echo "$@" | jq &> /dev/null
        if [ "$?" -eq "0" ] ; then
            echo "$@" | jq
        else
            echo "$@"
        fi

    fi
}

check_liveness () {
    trap "$(shopt -p -o errexit)" RETURN
    xfail=0
    if [ "$1" == "--xfail" ] ; then
        xfail=1
        shift
    fi
    echo ">>> Check liveness $1"
    set +e
    RESPONSE="$(curl -s --fail-with-body $1)"
    CODE=$?
    if [ "$CODE" -gt "0" ] ; then
        [ "$xfail" -eq "1" ] || echo "$RESPONSE" | jq
        [ "$xfail" -eq "1" ] || echo "CODE $CODE"
    fi
    return $CODE
}

await_liveness () {
    _uri=$1
    _retry=5
    _counter=1
    while [ $_counter -lt $_retry ] ; do
        check_liveness --xfail "$_uri" && return 0
        ((++_counter))
        sleep 2
    done
    check_liveness "$_uri" && return 0
    echo "not alive: $_uri"
    exit 1
}

ASSET_ID="${ASSET_ID:-"$(uuidgen)"}"
create_asset () {
    trap "$(shopt -p -o errexit)" RETURN
    echo ">>> Create asset $ASSET_ID"
    export ASSET_ID
    #PAYLOAD="$(envsubst < resources/create-asset.json)"
    #set +e
    #RESPONSE="$(curl $CURL_OPTS --data "${PAYLOAD}" \
    #    -H "Authorization: Bearer $ACCESS_TOKEN" \
    #    -H 'content-type: application/json' \
    #    ${PROVIDER_MANAGEMENT}/v3/assets \
    #)"
    RESPONSE="$(ACCESS_TOKEN=$ACCESS_TOKEN ./publish-linkahead.py "$ASSET_ID")"
    CODE=$?
    log $? "$RESPONSE"
    RESPONSE="$(curl $CURL_OPTS \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "${PROVIDER_MANAGEMENT}/v3/assets/$ASSET_ID")"
    log $? "$RESPONSE"

    return $CODE
}

POLICY_ID="${POLICY_ID:-"$(uuidgen)"}"
create_policy () {
    echo ">>> Create policy ${POLICY_ID}"
    export POLICY_ID
    PAYLOAD="$(envsubst < resources/create-policy.json)"

    RESPONSE="$(curl $CURL_OPTS --data "${PAYLOAD}" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H 'content-type: application/json' \
        ${PROVIDER_MANAGEMENT}/v3/policydefinitions\
    )"
    log $? "$RESPONSE"
}

list_policies () {
    _reset="$(shopt -p -o errexit || true)"
    echo ">>> List policies"
    set +e
    RESPONSE="$(curl $CURL_OPTS --data "{\"@context\":{\"@vocab\":\"https://w3id.org/edc/v0.0.1/ns/\"},\"@type\":\"QuerySpec\"}" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H 'content-type: application/json' \
        "${PROVIDER_MANAGEMENT}/v3/policydefinitions/request"\
    )"
    log $? "$RESPONSE"
}


get_policy () {
    _reset="$(shopt -p -o errexit || true)"
    echo ">>> Get policy $POLICY_ID"
    set +e
    RESPONSE="$(curl $CURL_OPTS \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "${PROVIDER_MANAGEMENT}/v3/policydefinitions/$POLICY_ID"\
    )"
    log $? "$RESPONSE"
}

create_contract_def () {
    echo ">>> Create contract definition"
    export POLICY_ID
    export ASSET_ID
    export CONTRACT_DEF_ID="$(uuidgen)"
    PAYLOAD="$(envsubst < resources/create-contract-definition.json)"
    log $? "$PAYLOAD"

    RESPONSE="$(curl $CURL_OPTS --data "${PAYLOAD}" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H 'content-type: application/json' \
        ${PROVIDER_MANAGEMENT}/v3/contractdefinitions \
    )"
    log $? "$RESPONSE"
}

list_contract_definitions () {
    _reset="$(shopt -p -o errexit || true)"
    echo ">>> List contract definitions"
    set +e
    RESPONSE="$(curl $CURL_OPTS --data "{\"@context\":{\"@vocab\":\"https://w3id.org/edc/v0.0.1/ns/\"},\"@type\":\"QuerySpec\"}" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H 'content-type: application/json' \
        "${PROVIDER_MANAGEMENT}/v3/contractdefinitions/request"\
    )"
    log $? "$RESPONSE"
}

OFFER_ID=${OFFER_ID:-}
fetch_catalog () {
    echo ">>> Fetch catalog from $PROVIDER_DSP"
    export PROVIDER_DSP
    PAYLOAD="$(envsubst < resources/fetch-catalog.json)"

    RESPONSE="$(curl $CURL_OPTS -X POST \
        "${CONSUMER_MANAGEMENT}/v3/catalog/request" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H 'Content-Type: application/json' \
        --data "${PAYLOAD}")"
    log $? "$RESPONSE"
    OFFER_ID="$(echo "$RESPONSE" \
        | jq --raw-output --arg ASSET_ID "$ASSET_ID" \
        '."dcat:dataset" | if type == "array" then . else [.] end | .[] | select(.id == $ASSET_ID)."odrl:hasPolicy"."@id"')"
}

get_data_set () {
    echo ">>> Get data set ${ASSET_ID} from $PROVIDER_DSP"
    export PROVIDER_DSP
    export ASSET_ID
    PAYLOAD="$(envsubst < resources/get-dataset.json)"

    RESPONSE="$(curl $CURL_OPTS -X POST \
        "${CONSUMER_MANAGEMENT}/v3/catalog/dataset/request/" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H 'Content-Type: application/json' \
        --data "${PAYLOAD}")"
    log $? "$RESPONSE"
    OFFER_ID="$(echo "$RESPONSE" \
        | jq --raw-output '."odrl:hasPolicy"."@id"')"
}

CONTRACT_ID=${CONTRACT_ID:-}
negotiate_contract () {
    echo ">>> Negotiate contract for offer $OFFER_ID"
    export OFFER_ID
    export PROVIDER_DSP
    PAYLOAD="$(envsubst < resources/negotiate-contract.json)"

    RESPONSE="$(curl $CURL_OPTS -X POST \
        -H 'content-type: application/json' \
        --data "$PAYLOAD" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        ${CONSUMER_MANAGEMENT}/v3/contractnegotiations)"
    log $? "$RESPONSE"
    CONTRACT_ID="$(echo "$RESPONSE" \
        | jq --raw-output '."@id"')"
}


CONTRACT_AGREEMENT_ID=
_retry_get_contract_agreement () {
    echo ">>> Get contract agreement $CONTRACT_ID"

    RESPONSE="$(curl -X GET \
        --header 'Content-Type: application/json' \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "${CONSUMER_MANAGEMENT}/v3/contractnegotiations/${CONTRACT_ID}" \
        $CURL_OPTS)"
    log $? "$RESPONSE"
    CONTRACT_AGREEMENT_ID="$(echo "$RESPONSE" \
        | jq --raw-output '.contractAgreementId')"
}

get_contract_agreement () {
    _counter=0
    _retry=5
    while [ $_counter -lt $_retry ] ; do
        _retry_get_contract_agreement
        [ "$CONTRACT_AGREEMENT_ID" == "null" ] || break
        ((++_counter))
        sleep 2
    done
    if [ "$CONTRACT_AGREEMENT_ID" == "null" ] ; then
        echo "contract agreement did not finish on time"
        exit 1
    fi
}

DATA_DESTINATION=
create_upload_destination () {
    echo -n ">>> Create upload destination "
    PAYLOAD="$(curl $CURL_OPTS -D - -X POST \
        -H "Tus-Resumable: 1.0.0" \
        -H "Upload-Defer-Length: 1" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        $CONSUMER_TUS_SERVER)"
    DATA_DESTINATION="${CONSUMER_DATA_DESTINATION}$(echo "$PAYLOAD" \
        | grep -e "Location" \
        | tr -d '\r' \
        | sed "s|Location: $CONSUMER_TUS_SERVER||")"
    echo "${DATA_DESTINATION}"
}

TRANSFER_PROCESS_ID="${TRANSFER_PROCESS_ID:-}"
start_transfer_push () {
    echo ">>> Start transfer push $CONTRACT_AGREEMENT_ID"
    export DATA_DESTINATION
    export CONTRACT_AGREEMENT_ID
    export PROVIDER_DSP
    export UPLOAD_ACCESS_TOKEN=$ACCESS_TOKEN
    PAYLOAD="$(envsubst < resources/start-transfer-push.json)"

    RESPONSE="$(curl -X POST \
        -H 'content-type: application/json' \
        --data "$PAYLOAD" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "${CONSUMER_MANAGEMENT}/v3/transferprocesses" \
        $CURL_OPTS)"
    log $? "$RESPONSE"
    TRANSFER_PROCESS_ID="$(echo "$RESPONSE" \
        | jq --raw-output '."@id"')"
}

TRANSFER_PROCESS_ID="${TRANSFER_PROCESS_ID:-}"
start_transfer_pull () {
    echo ">>> Start transfer pull $CONTRACT_AGREEMENT_ID"
    export CONTRACT_AGREEMENT_ID
    export PROVIDER_DSP
    PAYLOAD="$(envsubst < resources/start-transfer-pull.json)"

    RESPONSE="$(curl -X POST \
        -H 'content-type: application/json' \
        --data "$PAYLOAD" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "${CONSUMER_MANAGEMENT}/v3/transferprocesses" \
        $CURL_OPTS)"
    log $? "$RESPONSE"
    TRANSFER_PROCESS_ID="$(echo "$RESPONSE" \
        | jq --raw-output '."@id"')"
}

TRANSFER_STATE=
_retry_check_transfer () {
    echo ">>> Check transfer $TRANSFER_PROCESS_ID"
    RESPONSE="$(curl $CURL_OPTS \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        "${CONSUMER_MANAGEMENT}/v3/transferprocesses/$TRANSFER_PROCESS_ID")"
    log $? "$RESPONSE"
    TRANSFER_STATE="$(echo "$RESPONSE" \
        | jq --raw-output '.state')"
}

CHECK_TRANSFER_RETRY=${CHECK_TRANSFER_RETRY:-10}
CHECK_TRANSFER_WAIT=${CHECK_TRANSFER_WAIT:-5}
check_transfer () {
    _wait_for_state="COMPLETED"
    if [ "${1:-}" == "STARTED" ] ; then
        _wait_for_state="STARTED"
        shift
    fi
    TRANSFER_PROCESS_ID="${TRANSFER_PROCESS_ID:-${1:-}}"
    _retry=${CHECK_TRANSFER_RETRY}
    _counter=0
    RESPONSE=
    while [ $_counter -lt $_retry ] ; do
        RESPONSE=
        _retry_check_transfer
        [ "$TRANSFER_STATE" != "$_wait_for_state" ] || break
        [ "$TRANSFER_STATE" != "TERMINATED" ] || break
        ((++_counter))
        sleep "${CHECK_TRANSFER_WAIT}"
    done
    if [ "$TRANSFER_STATE" != "$_wait_for_state" ] ; then
        log 1 "$RESPONSE"
        echo "transfer process did reach $_wait_for_state state on time: $TRANSFER_STATE"
        exit 1
    fi
}

ACCESS_TOKEN=
get_access_token () {
    _reset="$(shopt -p -o errexit || true)"
    echo -n ">>> Get access token "
    set +e
    RESPONSE="$(curl $CURL_OPTS -X POST \
        --data "grant_type=client_credentials&scope=${TOKEN_SCOPE}" \
        -H "Authorization: $TOKEN_CLIENT_AUTH_HEADER" \
        $TOKEN_SERVICE)"
    CODE="$?"
    if [ "$CODE" -gt "0" ] ; then
        echo "-> code $CODE"
        [ "$1" == "--xfail" ] || log $CODE "$RESPONSE"
        $_reset
        [ "$CODE" -eq "0" ]
        return $CODE
    fi
    ACCESS_TOKEN="$(echo $RESPONSE \
        | jq --raw-output '.access_token')"

    echo "$ACCESS_TOKEN"
    [ -n "$ACCESS_TOKEN" ] || [ "$1" == "--xfail" ] || echo "$RESPONSE"
    $_reset
    [ -n "$ACCESS_TOKEN" ]
}

validate_access_token () {
    _reset="$(shopt -p -o errexit || true)"
    echo ">>> Validate access token $ACCESS_TOKEN "
    set +e
    RESPONSE="$(curl -I $CURL_OPTS \
        -X GET \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        $TOKEN_VALIDATE_SERVICE || true)"

    if ! echo "$RESPONSE" | grep -c "HTTP/1\.1 20" > /dev/null
    then
        [ "$1" == "--xfail" ] || echo  "$RESPONSE"
    fi
    $_reset
    echo "$RESPONSE" | grep -c "HTTP/1\.1 20" > /dev/null
}
