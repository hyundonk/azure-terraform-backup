locals {
  location = "Koreacentral"
  RESOURCEGROUP = "backup_testrg"
}

resource "azurerm_resource_group" "example" {
  name     = local.RESOURCEGROUP
  location = local.location
}

resource "azurerm_storage_account" "example" {
  name     								 = "restore112"
	resource_group_name      = azurerm_resource_group.example.name
	location                 = azurerm_resource_group.example.location
	account_tier             = "Standard"
	account_replication_type = "LRS"
}

resource "azurerm_resource_group" "restore" {
  name     = "${local.RESOURCEGROUP}-restore"
  location = local.location
}

resource "azurerm_recovery_services_vault" "example" {
  name                = "recovery-vault112"
  location            = local.location
  resource_group_name = local.RESOURCEGROUP
  sku                 = "Standard"
}

/*
resource "azurerm_backup_policy_vm" "example" {
  name                = "recovery-vault-policy112"
  resource_group_name = local.RESOURCEGROUP
  recovery_vault_name = azurerm_recovery_services_vault.example.name

  timezone = "KST"

  backup {
    frequency = "Weekly"
    time      = "23:00"
  }

  retention_weekly {
    count    = 10
    weekdays = ["Sunday"]
  }
}
*/

module "virtual_network" {
  source  = "github.com/hyundonk/terraform-azurerm-caf-virtual-network"

  virtual_network_rg                = local.RESOURCEGROUP
  prefix                            = "back"
  location                          = local.location
  networking_object                 = {
    vnet = {
      name                = "-demo-vnet"
        address_space       = ["10.10.0.0/16"]
        dns                 = []
    }
    specialsubnets = {}

    subnets = {
      frontend   = {
        name                = "frontend"
        cidr                = "10.10.0.0/24"
        service_endpoints   = []
        nsg_name            = "nsg-frontend"
      }
			subnet-test = {
        name                = "subnet-test"
        cidr                = "10.10.1.0/24"
        service_endpoints   = []
        nsg_name            = "nsg-test"
      }
    }
  }
  tags            = {}
}

/*
module "nsg_rules" {
	source = "github.com/hyundonk/aztf-module-nsgrules"

	nsg_rules_table = {
		nsg-ad = {
			nsg_name          = "nsg-frontend"
			nsg_inbound   = [
			
			]
			nsg_outbound   = [
			
			]
		}
	}
	
	rg                      = local.RESOURCEGROUP
	location                = local.location
	tags                    = {}
}
*/

module "demo-vm" {
  source  = "github.com/hyundonk/aztf-module-vm"

  instances = {
    name          = "vmorig"
    prefix            = null
    postfix           = null

    vm_num        = 1
    vm_size       = "Standard_F4s"
    subnet        = "frontend"
    subnet_ip_offset  = 4
    vm_publisher      = "MicrosoftWindowsServer"
    vm_offer          = "WindowsServer"
    vm_sku            = "2016-Datacenter"
    vm_version        = "latest"
  }

  location                          = local.location
  resource_group_name               = local.RESOURCEGROUP

  subnet_id                         = module.virtual_network.subnet_ids_map["frontend"]
  subnet_prefix                     = module.virtual_network.subnet_prefix_map["frontend"]

  admin_username                    = var.adminusername
  admin_password                    = var.adminpassword
}


