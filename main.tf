# Create Resource Group
module "resource_group" {
  source   = "./modules/resource_group"
  name     = "nodejs-docker-rg"
  location = var.location
  rg_name  = "nodejs-docker-rg"
}

# Create Network Resources
module "network" {
  source                  = "./modules/network"
  location                = var.location
  resource_group_name     = module.resource_group.name
  vnet_name               = "nodejs-vnet"
  vnet_address_space      = ["10.0.0.0/16"]
  subnet_name             = "nodejs-subnet"
  subnet_prefix           = ["10.0.1.0/24"]
  subnet_address_prefixes = ["10.0.1.0/24"]
}

# Create Security Group
module "security_group" {
  source              = "./modules/security_group"
  location            = var.location
  resource_group_name = module.resource_group.name
  nsg_name            = "nodejs-nsg"
  rg_name             = module.resource_group.name
}

# Create Virtual Machine
module "virtual_machine" {
  source              = "./modules/virtual_machine"
  location            = var.location
  resource_group_name = module.resource_group.name
  vm_name             = "nodejs-vm"
  subnet_id           = module.network.subnet_id
  nsg_id              = module.security_group.nsg_id
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  nic_name            = "nodejs-nic"
  public_ip_name      = "nodejs-public-ip"
}
