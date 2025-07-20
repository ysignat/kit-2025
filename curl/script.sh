#!/usr/bin/env sh

set -eu

CLOUD_INIT=$(cat cloud-init-master.yml)
DATA=$(jq ". + {\"metadata\": {\"user-data\": \"${CLOUD_INIT}\"}}" curl/data.json)
IAM_TOKEN=$(yc iam create-token)

curl -X POST https://compute.api.cloud.yandex.net/compute/v1/instances \
    --data "${DATA}" \
    --header "Authorization: Bearer ${IAM_TOKEN}"

