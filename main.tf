terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ed8624b9-ba87-4776-a59b-2f59727a7359"
}

#create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = "East US"

}

#Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

}

#Create a Subnet
resource "azurerm_subnet" "pubsub" {
  name                 = "pubsub"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]

}

#Create a public ip
resource "azurerm_public_ip" "ip" {
  name                = "ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"

}

#Create a Network Interface 
resource "azurerm_network_interface" "nic" {
  name                = "nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pubsub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.ip.id
  }

}

#Create a Network Security Group
resource "azurerm_network_security_group" "nsg" {
    name = "nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
    name                       = "test"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    }
}

#Associate Netwrok security group to Virtual Machine
resource "azurerm_network_interface_security_group_association" "nsgass" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  network_interface_id = azurerm_network_interface.nic.id
}

#Create a Linux Virtual Machine 
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "jane"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]


  admin_ssh_key {
    username   = "jane"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

#create Azure Virtual machine Image
resource "azurerm_image" "vmimage" {
    name = "apacheserver"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    source_virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  
}