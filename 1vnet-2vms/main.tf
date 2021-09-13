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
    location = "westeurope"
    tags      = {
      Environment = "DEV"
      createdby = "martins.galins"
    }
}