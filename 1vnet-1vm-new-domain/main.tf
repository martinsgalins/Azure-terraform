#create resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location
  tags = {
    Environment = "DEV"
    createdby   = "martins.galins"
  }
}
#create VNET
resource "azurerm_virtual_network" "VNET1" {
  name                = "VNET-DEV-AD"
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
  admin_username             = var.LocalAdmin
  admin_password             = var.LocalAdminPassword

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "Server1-OSdisk01"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = {
    environment = "DEV"
  }
}

resource "azurerm_virtual_machine_extension" "DomainControllerSetup" {
  name                 = "DomainControllerSetup"
  virtual_machine_id   = azurerm_windows_virtual_machine.Server1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {    
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.DomainControllerSetup.rendered)}')) | Out-File -filepath DomainControllerSetup.ps1\" && powershell -ExecutionPolicy Unrestricted -File DomainControllerSetup.ps1 -DomainName ${data.template_file.DomainControllerSetup.vars.domainname} -dsrm ${data.template_file.DomainControllerSetup.vars.dsrm}" 
  }
  
  SETTINGS
}

data "template_file" "DomainControllerSetup" {
  template = file("DomainControllerSetup.ps1")
  vars = {
    domainname = var.DomainName
    dsrm       = var.DSRM
  }
}