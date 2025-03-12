provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}
provider "azapi" {
  
##  use_cli = true
  
}
# ## used if mutliple subscriptions are used
# provider "azurerm" {
#   features {
#     resource_group {
#       prevent_deletion_if_contains_resources = false
#     }
#   }
#   alias           = "connectivity"
#   subscription_id = var.platform_connectivity_subscription
# }
