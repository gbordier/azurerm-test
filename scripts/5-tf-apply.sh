if [ -z "$config" ]; then
    echo "  set config variable first to the prefix of your variables file"
    exit 1
fi

if [ ! $(echo $(pwd) | grep 'tf') ] ; then
    echo " you must be in a terraform folder , cd to a terraform folder then run this script"
    exit 1
fi

[ -z TF_RESOURCE_GROUP_NAME ] && . ./0-init-vars-from-file.sh


if [ ! -f $mainconfigfile ] || [ -z  TF_CONTAINER_NAME ] || [ -z TF_RESOURCE_GROUP_NAME ]; then
   echo "error no storage account found for TF "
    exit 1
fi


export ARM_USE_AZUREAD=true
export ARM_STORAGE_USE_AZUREAD=true

terraform apply tfplan