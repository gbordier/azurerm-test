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


## sourcing the main var files
[ -z TF_RESOURCE_GROUP_NAME ] && . ./0-init-vars-from-file.sh


if [ ! -f $mainconfigfile ] || [ -z  TF_CONTAINER_NAME ] || [ -z TF_RESOURCE_GROUP_NAME ]; then
   echo "error no storage account found for TF "
    exit 1
fi


echo "tf init with $STORAGE_ACCOUNT and $RESOURCE_GROUP on $CONTAINER_NAME"

export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true


terraform init -backend-config="storage_account_name=$TF_STORAGE_ACCOUNT_NAME" -backend-config="container_name=$TF_CONTAINER_NAME" -backend-config="resource_group_name=$TF_RESOURCE_GROUP_NAME" -backend-config="key=tfstate.${currentmodule}"

