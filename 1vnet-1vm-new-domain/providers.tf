terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.89.0"
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