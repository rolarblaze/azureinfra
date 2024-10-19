terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = ""
}

# Create a Resource Group
resource "azurerm_resource_group" "KingRG" {
  name = "KingRG"
  location = "East US"
}


# Create a Virtual Network
resource "azurerm_virtual_network" "KingVnet" {
  name                = "KingVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.KingRG.location
  resource_group_name = azurerm_resource_group.KingRG.name
}