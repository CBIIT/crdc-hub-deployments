#!/bin/bash
set -x

TIER=dev
REPOSITORY=https://github.com/CBIIT/crdc-hub-deployments.git
SOURCE_DIR=~/$TIER

rm -rf $SOURCE_DIR
mkdir -p ~/$TIER
git clone $REPOSITORY $SOURCE_DIR

cd $SOURCE_DIR/terraform
./setup.sh
aws s3 cp s3://crdc-dh-terraform-remote-state/env/dev/crdc-dh/crdc-dh-dev.tfvars .

terraform init --reconfigure -backend-config=crdc-dh.tfbackend

# If the workspace exists, select it. If not, create a new one.
if terraform workspace list | grep -q "$TIER"; then
  terraform workspace select "$TIER"
else
  terraform workspace new "$TIER"
fi

terraform workspace list

terraform plan -var-file crdc-dh-dev.tfvars
terraform apply -var-file crdc-dh-dev.tfvars

