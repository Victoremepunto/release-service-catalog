#!/usr/bin/env bash

TASK_PATH="$1"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Add mocks to the beginning of task step script
yq -i '.spec.steps[1].script = load_str("'$SCRIPT_DIR'/mocks.sh") + .spec.steps[1].script' "$TASK_PATH"

# Create a dummy secret (and delete it first if it exists)
kubectl delete secret marketplacesvm-test-secret --ignore-not-found
kubectl create secret generic marketplacesvm-test-secret \
  --from-literal=aws-na.json='{
    "marketplace_account": "aws-na",
    "auth": {
        "AWS_IMAGE_ACCESS_KEY": "AK-TEST-NA",
        "AWS_IMAGE_SECRET_ACCESS": "sa-test-na-secret",
        "AWS_MARKETPLACE_ACCESS_KEY": "AK-TEST-NA-MKT",
        "AWS_MARKETPLACE_SECRET_ACCESS": "sa-test-na-mkt-secret",
        "AWS_ACCESS_ROLE_ARN": "arn:aws:iam::555555555555:role/AWSMarketplaceScanning",
        "AWS_GROUPS": [],
        "AWS_SNAPSHOT_ACCOUNTS": [],
        "AWS_REGION": "us-east-1"
    }
}' \
  --from-literal=aws-emea.json='{
    "marketplace_account": "aws-emea",
    "auth": {
        "AWS_IMAGE_ACCESS_KEY": "AK-TEST-EMEA",
        "AWS_IMAGE_SECRET_ACCESS": "sa-test-emea-secret",
        "AWS_MARKETPLACE_ACCESS_KEY": "AK-TEST-EMEA-MKT",
        "AWS_MARKETPLACE_SECRET_ACCESS": "sa-test-emea-mkt-secret",
        "AWS_ACCESS_ROLE_ARN": "arn:aws:iam::555555555555:role/AWSMarketplaceScanning",
        "AWS_GROUPS": [],
        "AWS_SNAPSHOT_ACCOUNTS": [],
        "AWS_REGION": "eu-central-1"
    }
}'
