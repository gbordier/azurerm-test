#!/bin/bash



if [ ! "$0" = "-bash" ] && [ !  -z $BASH_SOURCE ]; then
    echo "dotsource this file using . $0" 
    exit
fi


if [ ! -z "$BASH_SOURCE" ]; then
    scriptdir=$(dirname $BASH_SOURCE)
fi


if [ -z "$config" ]; then
    echo "export config=<yourconfig> variable first to the prefix of your variables file"
    return
fi
pushd $scriptdir
vardir=../variables
configfile=$vardir/$config.parameters.json

export RESOURCE_GROUP=$(cat $configfile  | jq -r ".resource_group_name")
export LOCATION=$(cat $configfile  | jq -r ".location")
export SUBSCRIPTION_ID=$(cat $configfile  | jq -r ".subscription_id")
export TF_RESOURCE_GROUP_NAME=$(cat $configfile  | jq -r ".tf_resource_group_name")
export TF_STORAGE_ACCOUNT_NAME=$(cat $configfile  | jq -r ".tf_storage_account_name")

export CLIENT_ID=$(cat $configfile  | jq -r ".client_id")


export ARM_TENANT_ID=$(cat $configfile  | jq -r ".tenant_id")
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true
export TF_CONTAINER_NAME=tfstate${config}
export TF_CONTAINER_NAME=$(cat $configfile  | jq -r ".tf_container_name")
export TF_KEY_NAME=tfstate.main
popd