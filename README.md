# azurerm-test

This is a template TF code for azure
 - using azure storage account as the backend store for TF state
 - using a sub workflow to get environment variables
 - uses a variables file in the variables folder for each config (the config variable should be set accordingly)
 
 The goal for this sample is to have *only* no credential used by terraform, only Azure CLI generated token.

This way the exact same authentication can be used from a github action or from the command line and no authenticatoin specific config is needed


- the azurerm provider has been allowing using az login for some time (v1.5.11) BUT the authentication to azure for the state (backend ) did not work this way.
- terraform v11 now allows azure backend access using az login (retrieving a token from `az account get-access-token` command line)
- similarly the azapi provider can also leverage the entra ID access token this which prevents the timeout issue from happening again (previously the short lived 12 minutes OIDC token was not renewable with the azapi provider which made any azapi call happenning after 12 minutes from the last azurerm creation fail)



 This sample has a set of companion scripts to run the steps from the command line during testing (script folder) before using a pipeline.

 - 0-init-vars-from-file.sh need to be dot-sourced to import variables (. ../scripts/0-init-vars-from-file.sh ) and it will
   - read from the xxx.parameters.json file and fill the required env variables

 - 1-bootstrap-tfstate.sh will then
    - create resource group and storage account for TF state
    - allow local IP to access the storage account
    - create "federated credential" in the *existing* Entra ID application for the current branch of this repo in the service principal object (a github action running in this branch will use the SP identity to connect to azure )
    - grant access to both the *logged on user* and the CLIENT_ID for the service principal to the storage account
 - 2-tf-init.sh will then initialize the state
 - 3-tf-plan.sh will create the pan 
 - 4-tf-apply.sh will deploy the content of the tf folder

not that the terraform state file (key) will be auto generated from the current TF folder parent name or defaults to tfstate.main if there is a single tf folder in the repo

the application that will carry the federated credentials must exist first and its appid be referenced into the variable file.

```
## to create the app used to deploy
CLIENT_ID=$(az ad sp create-for-rbac --name myapp  | jq -r .appId)
##assign  contributor role for the app 
az role assignment create --role "Contributor" --assignee $CLIENT_ID --scope /subscriptions/$ARM_SUBSCRIPTION_ID

```

A typical variable file would be (see variables folder)

``` json
{
  "resource_group_name": "yourtargetresourcegroup",
  "location": "northeurope",
  "private_deployment": true,
  "subscription_id": "d649ef3f-c6b9-4a5b-b0dd-ffffffff",  
  "tenant_id": "9e457c18-ff0d-433f-bfc3-ffffffff",
  "client_id": "49081be5-d6fd-4ab1-b02e-ffffffff", // must be created first !!
  "tf_resource_group_name": "your-tf-state-rg",
  "tf_storage_account_name": "yourazrmtesttfstate",
  "tf_container_name": "tfstate",
  "prefix":"azrmtest",
  "sleep_after_script":"30s"
}
```


To run from the command line use:
 ``` bash
cd tf
## set point config to the variable file prefix
export config=myconfig ## read ../variables/myconfig.parameters.json
## load variables (dot source the script)
 . ../scripts/0-init-vars-from-file.sh
## init terraform state in azure storage account (you may need to add -migrate or -reconfigure if you are reusing a previous state, otherwise just delete the state file from the azure storage account)
../scripts/2-tf-init.sh

## plan and apply
../scripts/3-tf-plan.sh
../scripts/5-tf-apply.sh

## destroy the all thing
../scripts/5-tf-destroy.sh


 ```

 Once everything has worked from the command line, the terraform.yml pipeline can be used to continue deployment

terraform.yml will call into load-config.yml to read variables from the same variable file.
