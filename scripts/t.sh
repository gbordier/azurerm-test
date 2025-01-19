#!/bin/bash
repo=$(basename $(git rev-parse --show-toplevel))
branch=$(git branch --show-current)
org=$(git remote get-url origin | awk -F'/' '{print $4}')
( [ -z $branch ] ||  [ -z $repo ] ||  [ -z $org ] )  || ( 
    if (az ad app federated-credential list --id $CLIENT_ID --query "[?issuer=='https://token.actions.githubusercontent.com/']" | grep -i $repo); then
        echo "federated credential already created for $repo"
    else
        echo "creating federated credential for $repo"
        
        cat > /tmp/federated-credential.json <<EOF
        {
            "name": "credential",
            "issuer": "https://token.actions.githubusercontent.com/",
            "subject": "repo:$org/$repo:refs/heads/$branch",
            "description": "Testing",
            "audiences": [
                "api://AzureADTokenExchange"
            ]
        }
EOF
        az ad app federated-credential create --id $CLIENT_ID --parameters /tmp/federated-credential.json
        ##az role assignment create --role "Storage Blob Data Contributor" --assignee $CLIENT_ID --scope $TF_RESOURCE_GROUP
    fi
)