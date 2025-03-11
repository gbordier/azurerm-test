resource "azapi_resource" "example" {
  type      = "Microsoft.ContainerRegistry/registries@2020-11-01-preview"
  name      = "acrnamesample"
  parent_id = azurerm_resource_group.spoke.id

  location = azurerm_resource_group.spoke.location


  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      adminUserEnabled = true
    }
  }

  tags = {
    "Key" = "Value"
  }

    depends_on = [  
    azurerm_resource_group.spoke,
    time_sleep.wait_after_script
    ]
  response_export_values = ["properties.loginServer", "properties.policies.quarantinePolicy.status"]
}