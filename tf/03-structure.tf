resource "azurerm_resource_group" "main-rg" {
  name = "${var.prefix}-${var.env}-main-rg"
  location = var.location

  tags = {
    env = "${var.prefix}-${var.env}"
  }
}

resource "azurerm_resource_group" "spoke" {
  name = "${var.prefix}-${var.env}-spoke-rg"
  location = var.location

  tags = {
    env = "${var.prefix}-${var.env}"
  }
}

## this introcues a delay after the script execution 
## test azapi token validaity 
resource "time_sleep" "wait_after_script" {
  depends_on = [azurerm_resource_group.spoke]

  create_duration = var.sleep_after_script

}

