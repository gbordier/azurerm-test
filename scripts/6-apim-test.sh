#!/bin/bash
if [ -z "$core_function_name" ]; then
    echo "run ./0-init-vars.sh script first to set core_function_name"
    exit 1
fi
n=$(jq -r .apim_settings.name $configPath)
g=$resource_group_name

id=$(az apim show -n $n -g $g --query id -o tsv)
subname=$(az rest --method get --uri "$id/subscriptions?api-version=2022-08-01" --query "value[? properties.displayName == 'default-admin-subscription' ].name" -o TSV)
primaryKey=$(az rest --method post --uri "$id/subscriptions/$subname/listSecrets?api-version=2022-08-01" --query primaryKey -o tsv)
url=$(az apim show -n $n -g $g --query gatewayUrl -o tsv)
curl --location --globoff "$url/admin/health" -H "Content-Type: application/json" -H "api-key: $primaryKey" 

 