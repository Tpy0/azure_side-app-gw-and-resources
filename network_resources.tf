resource "azurerm_resource_group" "az-waf-rg" {
  name     = "az-waf-rg0"
  location = "West Us"
}
resource "azurerm_network_security_group" "az-waf-nsg" {
  name                = "az-waf-nsg0"
  location            = local.loc
  resource_group_name = local.rg_name

  security_rule {
    name                       = "inbound-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "172.56.105.159/32"
    destination_address_prefix = "*"
  }
 security_rule {
    name                       = "inbound-http-81"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "81"
    source_address_prefix      = "172.56.105.159/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-infra-ports"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "az-waf-vnet" {
  name                = "az-waf-vnet0"
  location            = local.loc
  resource_group_name = local.rg_name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "az-waf-sub-0" {
  name                 = "az-waf-sub-0"
  resource_group_name  = local.rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "az-waf-sub-1" {
  name                 = "az-waf-sub-1"
  resource_group_name  = local.rg_name
  virtual_network_name = local.vnet_name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_subnet_network_security_group_association" "az-waf-sub-nsg-a" {
  subnet_id                 = local.sub1_id
  network_security_group_id = local.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "az-waf-sub-nsg-a2" {
  subnet_id                 = local.sub0_id
  network_security_group_id = local.nsg_id
}

#----------------------configuration for back-end machine 1---------------#

resource "azurerm_network_interface" "az-waf-net-int" {
  name                = "server-nic"
  location            = local.loc
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.sub1_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.200"
  }
}

resource "azurerm_network_interface_security_group_association" "az-waf-nsg-int-a" {
  network_interface_id      = azurerm_network_interface.az-waf-net-int.id
  network_security_group_id = local.nsg_id
}

resource "azurerm_linux_virtual_machine" "az-waf-vm" {
  name                = "az-waf-vm-1"
  resource_group_name = local.rg_name
  location            = local.loc
  size                = "Standard_B1s"
  admin_username      = "wildes"
  network_interface_ids = [
    azurerm_network_interface.az-waf-net-int.id,
  ]

  custom_data = filebase64("azure-user-data.sh")

  admin_ssh_key {
    username   = "wildes"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

#--------------------------configuration for back-end machine 2 ---------------#

resource "azurerm_network_interface" "az-waf-net-int-2" {
  name                = "server-nic2"
  location            = local.loc
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.sub1_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.201"
  }
}

resource "azurerm_network_interface_security_group_association" "az-waf-nsg-int-a-2" {
  network_interface_id      = azurerm_network_interface.az-waf-net-int-2.id
  network_security_group_id = local.nsg_id
}

resource "azurerm_linux_virtual_machine" "az-waf-vm-2" {
  name                = "az-waf-vm-2"
  resource_group_name = local.rg_name
  location            = local.loc
  size                = "Standard_B1s"
  admin_username      = "wildes"
  network_interface_ids = [
    azurerm_network_interface.az-waf-net-int-2.id,
  ]

  custom_data = filebase64("azure-user-data.sh")

  admin_ssh_key {
    username   = "wildes"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
