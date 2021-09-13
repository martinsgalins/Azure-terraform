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
  address_prefixes     = ["10.5.2.0/24"]
}
resource "azurerm_subnet" "ServerSubnet2" {
  name                 = "ServerSubnet2"
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.VNET1.name
  address_prefixes     = ["10.5.1.0/24"]
}