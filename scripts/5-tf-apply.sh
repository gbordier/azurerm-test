if [ -z "$config" ]; then
    echo "  set config variable first to the prefix of your variables file"
    exit 1
fi

if [ ! $(echo $(pwd) | grep 'tf') ] ; then
    echo " you must be in a terraform folder , cd to a terraform folder then run this script"
    exit 1
fi

export ARM_TENANT_ID=$(az account show --query 'tenantId' -o TSV )
export ARM_SUBSCRIPTION_ID=$subscription_id
export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true

terraform apply tfplan