# azurerm-test

This is a template TF code for azure
 - using azure storage account as the backend store for TF state
 - using a sub workflow to get environment variables
 - uses a variables file in the variables folder for each config (the config variable should be set accordingly)



 This sample has a set of companion scripts to run the steps from the command line during testing (script folder) before using a pipeline.

 - 0-init-vars-from-file.sh need to be dot-sourced to import variables (. ./scripts/0-init-vars-from-file.sh ) and it will
   - read from the xxx.parameters.json file and fill the required env variables

 - 1-bootstrap-tfstate.sh will then
    - create resource group and storage account for TF state
    - allow local IP to access the storage account
    - create "federated credential" in Entra ID  for the current branch of this repo in the service principal object (a github action running in this branch will use the SP identity to connect to azure )
    - grant access to both the local user and the CLIENT_ID for the service principal to the storage account
 - 2-tf-init.sh will then initialize the state
 - 3-tf-plan.sh will create the pan 
 - 4-tf-apply.sh will deploy the content of the tf folder


 once everything has worked from the command line, the terraform.yml pipeline can be used to continue deployment