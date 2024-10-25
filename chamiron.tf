#am creating a vnet from terraform  as part of my collaboration work
resource "azurerm_resource_group" "chamiron-resource_group" {
  name     = "chamiron-resource_group"
  location = "West Europe"
}

resource "azurerm_network_security_group" "chami-nsg" {
  name                = "chami-nsg"
  location            = azurerm_resource_group.chamiron-resource_group.location
  resource_group_name = azurerm_resource_group.chamiron-resource_group.name
}

resource "azurerm_virtual_network" "chami-vnet" {
  name                = "chami-vnet"
  location            = azurerm_resource_group.chamiron-resource_group.location
  resource_group_name = azurerm_resource_group.chamiron-resource_group.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "subnet2"
    address_prefixes = ["10.0.2.0/24"]
    security_group   = azurerm_network_security_group.chami-nsg
  }

  tags = {
    environment = "Production"
  }
}