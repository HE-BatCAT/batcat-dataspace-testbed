#!/usr/bin/env python3

import sys
import os
import json
import requests
import linkahead as la

#ASSET_ID = sys.argv[1]

host = os.environ.get("HOSTNAME")
ACCESS_TOKEN = os.environ.get("ACCESS_TOKEN")
PROVIDER_PRIVATE=f"http://{host}:9001"
PROVIDER_MANAGEMENT=f"{PROVIDER_PRIVATE}/management"
PROVIDER_LINKAHEAD=f"{PROVIDER_PRIVATE}/linkahead"

template = {
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
  },
  "@id": None,
  "properties": {
    "role": None,
    "name": None,
    "description": None,
    "contenttype": "text/xml",
  },
  "dataAddress": {
    "type": "HttpData",
    "baseUrl": None,
    "authKey": "Authorization",
    "authCode": f"Bearer {ACCESS_TOKEN}"
  }
}

def get_base_url(entity_id):
    return f"{PROVIDER_LINKAHEAD}/Entity/" + str(entity_id)

def to_asset_json(entity):
    template["@id"] = str(entity.id)
    template["properties"]["state"] = "public"
    template["properties"]["role"] = entity.role
    template["properties"]["name"] = entity.name
    template["properties"]["description"] = entity.description
    template["dataAddress"]["baseUrl"] = get_base_url(entity.id)

    return json.dumps(template)

def publish(assets):
    for a in assets:
        print('{ "in":')
        print(a)
        print(', "out":')
        response = requests.post(
            url=f"{PROVIDER_MANAGEMENT}/v3/assets",
            data=a,
            headers={
                "authorization": f"Bearer {ACCESS_TOKEN}",
                "content-type": "application/json"}
            )
        print(response.text)
        print('}')

def create_record_type():
    c = la.execute_query("FIND ENTITY")
    if len(c) == 0:
        c = la.Container()
        c.append(la.RecordType(name="Test", description="Test Desc"))
        c.insert()
    return c

c = create_record_type()

assets = []
for e in c:
    assets.append(to_asset_json(e))

publish(assets)
