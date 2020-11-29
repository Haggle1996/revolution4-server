resource "azurerm_subnet" "r4-subnet-private" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.r4.name
  virtual_network_name = azurerm_virtual_network.r4-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "r4-nic" {
  name                = "r4-server-nic"
  location            = azurerm_resource_group.r4.location
  resource_group_name = azurerm_resource_group.r4.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.r4-subnet-private.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_linux_virtual_machine" "r4-server" {
  name                = "r4server"
  resource_group_name = azurerm_resource_group.r4.name
  location            = azurerm_resource_group.r4.location
  size                = "Standard_D2s_v3"
  admin_username      = "r4adminuser"

  network_interface_ids = [azurerm_network_interface.r4-nic.id]

  admin_ssh_key {
    username   = "r4adminuser"
    public_key = file("~/.ssh/r4server.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_managed_disk" "r4server-disk" {
  name                 = "r4server-disk"
  location             = azurerm_resource_group.r4.location
  resource_group_name  = azurerm_resource_group.r4.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 20
}

resource "azurerm_virtual_machine_data_disk_attachment" "r4server-disk-attch" {
  managed_disk_id    = azurerm_managed_disk.r4server-disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.r4-server.id
  lun                = 10
  caching            = "ReadWrite"
}

resource "azurerm_network_security_group" "r4server-nsg" {
  name                = "r4server-nsg"
  location            = azurerm_resource_group.r4.location
  resource_group_name = azurerm_resource_group.r4.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "r4server-nsg-assn" {
  subnet_id                 = azurerm_subnet.r4-subnet-private.id
  network_security_group_id = azurerm_network_security_group.r4server-nsg.id
}

resource "azurerm_virtual_machine_extension" "r4server-config" {
  name                 = "initialization"
  virtual_machine_id   = azurerm_linux_virtual_machine.r4-server.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "script": "${filebase64("init.sh")}"
    }
SETTINGS
}
