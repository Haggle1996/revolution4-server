resource "azurerm_subnet" "r4-subnet-firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.r4.name
  virtual_network_name = azurerm_virtual_network.r4-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "r4pip" {
  name                = "r4pip"
  location            = azurerm_resource_group.r4.location
  resource_group_name = azurerm_resource_group.r4.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "r4fw" {
  name                = "r4firewall"
  location            = azurerm_resource_group.r4.location
  resource_group_name = azurerm_resource_group.r4.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.r4-subnet-firewall.id
    public_ip_address_id = azurerm_public_ip.r4pip.id
  }
}

resource "azurerm_firewall_nat_rule_collection" "r4fwnat" {
  name                = "r4-nat-collection"
  azure_firewall_name = azurerm_firewall.r4fw.name
  resource_group_name = azurerm_resource_group.r4.name
  priority            = 100
  action              = "Dnat"

  rule {
    name                  = "AllowSSH"
    source_addresses      = ["*"]
    destination_ports     = ["22"]
    destination_addresses = [azurerm_public_ip.r4pip.ip_address]
    translated_port       = 22
    translated_address    = azurerm_network_interface.r4-nic.private_ip_address
    protocols             = ["TCP"]
  }
}
#     source_addresses      = ["73.20.14.251/32"]
