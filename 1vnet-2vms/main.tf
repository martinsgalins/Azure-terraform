provider "azurerm" {
    version = "2.9.0"
    subscription_id = var.subscriptionID
    client_id       = var.ApplicationID
    client_secret   = var.ClientSecret
    tenant_id       = var.TenantID
    features {}
}

#create resource group
resource "azurerm_resource_group" "rg" {
    name     = var.resourceGroupName
    location = var.location
    tags      = {
      Environment = "DEV"
      createdby = "martins.galins"
    }
}
#create VNET
resource "azurerm_virtual_network" "VNET1" {
  name                = "VNET-DEV-ZBX"
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = ["10.5.0.0/16"]
  dns_servers         = ["8.8.8.8", "8.8.4.4"]

  tags = {
    environment = "DEV"
    createdby = "martins.galins"
  }
}
#Add subnets to VNET
resource "azurerm_subnet" "ServerSubnet1" {
  name                 = "ServerSubnet1"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.5.1.0/24"]
}
resource "azurerm_subnet" "ServerSubnet2" {
  name                 = "ServerSubnet2"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.5.2.0/24"]
}
#create NICs for VMs
resource "azurerm_network_interface" "server1-nic01" {
  name                = "server1-nic01"
  location            = var.location
  resource_group_name = var.resourceGroupName

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ServerSubnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface" "server2-nic01" {
  name                = "server2-nic01"
  location            = var.location
  resource_group_name = var.resourceGroupName

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ServerSubnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_windows_virtual_machine" "Server1" {
  name                  = "Server1"
  location              = var.location
  resource_group_name   = var.resourceGroupName
  network_interface_ids = [azurerm_network_interface.server1-nic01.id]
  size               = "Standard_DS1_v2"
  allow_extension_operations = true
  provision_vm_agent = true
  admin_username = "azureuser"
  admin_password = "W3lcomeWorld12!!"
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    name              = "Server1-disk01"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "DEV"
  }
}


resource "azurerm_windows_virtual_machine" "Server2" {
  name                  = "Server2"
  location              = var.location
  resource_group_name   = var.resourceGroupName
  network_interface_ids = [azurerm_network_interface.server2-nic01.id]
  size               = "Standard_DS1_v2"
  allow_extension_operations = true
  provision_vm_agent = true
  admin_username = "azureuser"
  admin_password = "W3lcomeWorld12!!"
  
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name              = "Server2-disk01"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "DEV"
  }
}