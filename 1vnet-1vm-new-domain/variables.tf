variable "subscriptionID" {
  type        = string
  description = "Variable for our resource group"
}

variable "resourceGroupName" {
  type        = string
  description = "name of resource group"
}

variable "location" {
  type        = string
  description = "location of your resource group"
}

variable "TenantID" {
  type = string
}

variable "ApplicationID" {
  type = string
}

variable "ClientSecret" {
  type = string
}
variable "DSRM" {
  type = string
}
variable "LocalAdmin" {
  type = string
}
variable "LocalAdminPassword" {
  type = string
}
variable "DomainName" {
  type = string
}