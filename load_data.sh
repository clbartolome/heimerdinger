#!/bin/bash

no_updates() # (id, api_url)
{
  RESPONSE=$(curl -o /dev/null -s -w "%{http_code}\n" \
    -X 'POST' "http://$2/servers" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
    "hostName": "'"win-cli-$1"'",
    "nodeName": "'"win-cli-$1.redhat.com"'",
    "version": "Microsoft Windows Server 2016 Datacenter",
    "updates": []
  }')
  if [ "$RESPONSE" == "201" ]; then
    echo "Server $1 created!"
  else
    echo "Server $1 not created! (Error: $RESPONSE"
  fi
}

single_update() # (id, api_url)
{
  RESPONSE=$(curl -o /dev/null -s -w "%{http_code}\n" \
    -X 'POST' "http://$2/servers" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
    "hostName": "'"win-cli-$1"'",
    "nodeName": "'"win-cli-$1.redhat.com"'",
    "version": "Microsoft Windows Server 2016 Datacenter",
    "updates": [
      {
        "id": "'"win-cli-$1-KB226761"'",
        "kb": "KB226761",
        "tittle": "Security Intelligence Update for Microsoft Defender Antivirus - KB226761 (Version 1.371.901.0)",
        "status": "OPEN",
        "categories": "category-1,category-2"
      }
    ]
  }')
  if [ "$RESPONSE" == "201" ]; then
    echo "Server $1 created!"
  else
    echo "Server $1 not created! (Error: $RESPONSE"
  fi
}

multiple_updates() # (id, api_url)
{
  RESPONSE=$(curl -o /dev/null -s -w "%{http_code}\n" \
    -X 'POST' "http://$2/servers" \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
    "hostName": "'"win-cli-$1"'",
    "nodeName": "'"win-cli-$1.redhat.com"'",
    "version": "Microsoft Windows Server 2016 Datacenter",
    "updates": [
      {
        "id": "'"win-cli-$1-KB226761"'",
        "kb": "KB226761",
        "tittle": "Security Intelligence Update for Microsoft Defender Antivirus - KB226761 (Version 1.371.901.0)",
        "status": "OPEN",
        "categories": "category-1,category-2"
      },
      {
        "id": "'"win-cli-$1-KB226762"'",
        "kb": "KB226762",
        "tittle": "Security Intelligence Update for Microsoft Defender Antivirus - KB2267612 (Version 1.371.901.0)",
        "status": "CLOSED",
        "categories": "category-1"
      }
    ]
  }')
  if [ "$RESPONSE" == "201" ]; then
    echo "Server $1 created!"
  else
    echo "Server $1 not created! (Error: $RESPONSE"
  fi
}

API_URL=$(oc get route heimerdinger-api -o jsonpath='{.status.ingress[0].host}' -n heimerdinger)

for i in {1..30}
do
  MODULE=$(expr $i % 3)
  if [ "$MODULE" -eq 0 ]; then
    MODULE=$(expr $i % 2)
    if [ "$MODULE" -eq 0 ]; then
      single_update $i $API_URL
    else
      multiple_updates $i $API_URL
    fi
  else
    no_updates $i $API_URL
  fi
done