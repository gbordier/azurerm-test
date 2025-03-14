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
currentmodule=$currentfoldernameparent
mainconfigfile=../variables/${config}.parameters.json
[ $(git rev-parse --show-cdup) == "../" ] && currentmodule=main

## sourcing the main var files
[ -z TF_RESOURCE_GROUP_NAME ] && . ./0-init-vars-from-file.sh


if [ ! -f $mainconfigfile ] || [ -z  TF_CONTAINER_NAME ] || [ -z TF_RESOURCE_GROUP_NAME ]; then
   echo "error no storage account found for TF "
    exit 1
fi





echo "tf init with $STORAGE_ACCOUNT and $RESOURCE_GROUP on $CONTAINER_NAME"
export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true


echo "create $TF_RESOURCE_GROUP_NAME rg and storage account $TF_STORAGE_ACCOUNT_NAME"

## [[ $(az account get-access-token -o tsv --query "expiresOn")  < $(date +"%Y-%m-%d %H:%M:%S") ]] &&  az login --tenant "$tenant_id"


if (az account get-access-token --query "tenant" -o tsv | grep -q $ARM_TENANT_ID); then
    echo "logon already ok"
else
    echo "loging to $ARM_TENANT_ID"
    az login  --tenant $ARM_TENANT_ID --use-device-code
    az account set --subscription $ARM_SUBSCRIPTION_ID
fi


az group create --name $TF_RESOURCE_GROUP_NAME --location $LOCATION
az storage account create --name $TF_STORAGE_ACCOUNT_NAME --resource-group $TF_RESOURCE_GROUP_NAME --location $LOCATION --sku Standard_LRS

## get my ip
myip=$(curl -s ifconfig.me)
az storage account network-rule add --account-name $TF_STORAGE_ACCOUNT_NAME --resource-group $TF_RESOURCE_GROUP_NAME --ip-address $myip --action Allow   

export TF_RESOURCE_GROUP="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$TF_RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$TF_STORAGE_ACCOUNT_NAME"
[ -z $CLIENT_ID ] || az role assignment create --role "Storage Blob Data Contributor" --assignee $CLIENT_ID --scope $TF_RESOURCE_GROUP
az storage container create --name $TF_CONTAINER_NAME --account-name $TF_STORAGE_ACCOUNT_NAME --auth-mode login


#userupn=$(az account show --query user.name -o tsv)
userid=$(az ad signed-in-user show --query "userPrincipalName" -o tsv)
#userid=$(az ad user list --query "[?mail=='$userupn'].userPrincipalName"  -o tsv )
az role assignment create --role "Storage Blob Data Contributor" --assignee $userid --scope $TF_RESOURCE_GROUP

repo=$(basename $(git rev-parse --show-toplevel))
branch=$(git branch --show-current)
org=$(git remote get-url origin | awk -F'/' '{print $4}')
( [ -z $branch ] ||  [ -z $repo ] ||  [ -z $org ] )  || ( 
    if (az ad app federated-credential list --id $CLIENT_ID --query "[?issuer=='https://token.actions.githubusercontent.com']" | grep -i $repo); then
        echo "federated credential already created for $repo"
    else
        echo "creating federated credential for $repo on branch $branch"
        
        cat > /tmp/federated-credential.json <<EOF
        {
            "name": "repo-$repo-branch-$branch",
            "issuer": "https://token.actions.githubusercontent.com",
            "subject": "repo:$org/$repo:ref:refs/heads/$branch",
            "description": "Testing",
            "audiences": [
                "api://AzureADTokenExchange"
            ]
        }
EOF
        az ad app federated-credential create --id $CLIENT_ID --parameters /tmp/federated-credential.json
        az role assignment create --role "Storage Blob Data Contributor" --assignee $CLIENT_ID --scope $TF_RESOURCE_GROUP
    fi
)