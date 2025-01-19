#!/bin/bash

if [ ! -z "$0" ] && [ ! "$0" = "-bash" ] && [ -z $BASH_SOURCE ]; then
    scriptdir=$(dirname $0)
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
source <(/usr/bin/pwsh ./GenerateConfigVars.ps1 -config "$config")

export ARM_TENANT_ID=$(az account show --query 'tenantId' -o TSV )
export ARM_SUBSCRIPTION_ID=$subscription_id
export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true


popd