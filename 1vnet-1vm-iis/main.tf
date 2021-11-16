terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.77.0"
    }
  }
}
provider "azurerm" {
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
  tags = {
    Environment = "DEV"
    createdby   = "martins.galins"
  }
}
#create Public IP
resource "azurerm_public_ip" "pip1" {
  name                = "server1-nic01-pip1"
  resource_group_name = var.resourceGroupName
  location            = var.location
  allocation_method   = "Static"

  tags = {
    environment = "DEV"
    createdby   = "martins.galins"
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
    createdby   = "martins.galins"
  }
}
#Add subnets to VNET
resource "azurerm_subnet" "ServerSubnet1" {
  name                 = "ServerSubnet1"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.5.1.0/24"]
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
    public_ip_address_id = azurerm_public_ip.pip1.id
  }
}
resource "azurerm_windows_virtual_machine" "Server1" {
  name                       = "Server1"
  location                   = var.location
  resource_group_name        = var.resourceGroupName
  network_interface_ids      = [azurerm_network_interface.server1-nic01.id]
  size                       = "Standard_DS1_v2"
  allow_extension_operations = true
  provision_vm_agent         = true
  admin_username             = "azureuser"
  admin_password             = "W3lcomeWorld12!!"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "Server1-disk01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "DEV"
  }
}
output "Server1_public_ip" {
  value = azurerm_public_ip.pip1.ip_address
}
resource "azurerm_virtual_machine_extension" "test" {
  name                 = "deploy-iis3"
  virtual_machine_id  = azurerm_windows_virtual_machine.Server1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"./install-iis.ps1; exit 0;\""
    }
SETTINGS
}