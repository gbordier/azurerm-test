#!/bin/bash

if [ -z "$config" ]; then
    echo "export config=<yourconfig> variable first to the prefix of your variables file"
    exit 1
fi



if [ ! $(echo $(pwd) | grep 'tf') ] ; then
    echo " you must be in a terraform folder , cd to a terraform folder then run this script"
    exit 1
fi

currentfoldernameparent=$(basename $(dirname $(pwd)))

mainconfigfile=../variables/${config}.parameters.json


currentmodule=main

if [ -f $mainconfigfile ]; then
    export STORAGE_ACCOUNT=$(jq -r .tf_storage_account_name < $mainconfigfile)
    export RESOURCE_GROUP=$(jq -r .tf_resource_group_name < $mainconfigfile)
else
   echo "error no storage account found for TF "
    exit 1
fi



export CONTAINER_NAME=tfstate${config}

echo "tf init with $STORAGE_ACCOUNT and $RESOURCE_GROUP on $CONTAINER_NAME"
export ARM_TENANT_ID=$(az account show --query 'tenantId' -o TSV )
export ARM_SUBSCRIPTION_ID=$subscription_id
export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true


terraform init -backend-config="storage_account_name=$TF_STORAGE_ACCOUNT_NAME" -backend-config="container_name=$CONTAINER_NAME" -backend-config="resource_group_name=$TF_RESOURCE_GROUP_NAME" -backend-config="key=tfstate.${currentmodule}"

