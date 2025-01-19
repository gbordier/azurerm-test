#!/bin/bash
if [ -z "$core_function_name" ]; then
    echo "run ./0-init-vars.sh script first to set core_function_name"
    exit 1
fi
func=$core_function_name
k=$(az functionapp keys list -n FUNC600-Guardian -g dan-guardian-rg --query 'masterKey' -o TSV)
funchost=$(az functionapp show -n FUNC600-Guardian -g dan-guardian-rg --query 'hostNames[0]' -o TSV)

echo "testing legal"
curl https://${funchost}/legal/tou -H "x-functions-key: $k" \
    -H "Content-Type: application/json" 

echo "testing enroll"
curl https://${funchost}/users/enroll  -H "x-functions-key: $k"  -X POST -H "Content-Type: application/json" --data "{\"firstName\" : \"John\",\"LastName\" : \"Bouu\", \"email\": \"toto@toto.com\", \"sku\" : \"eu\"}" 
