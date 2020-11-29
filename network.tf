resource "azurerm_virtual_network" "r4-vnet" {
  name                = "r4-vnet-private"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.r4.location
  resource_group_name = azurerm_resource_group.r4.name
}
