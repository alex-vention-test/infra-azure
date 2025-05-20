variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the VM will be connected"
  type        = string
}

variable "nsg_id" {
  description = "ID of the network security group"
  type        = string
}

variable "admin_username" {
  description = "Username for the VM admin"
  type        = string
}

variable "admin_password" {
  description = "Password for the VM admin"
  type        = string
  sensitive   = true
}

variable "nic_name" {
  description = "Name of the network interface"
  type        = string
  default     = ""
}

variable "public_ip_name" {
  description = "Name of the public IP"
  type        = string
  default     = ""
}

resource "azurerm_public_ip" "public" {
  name                = coalesce(var.public_ip_name, "${var.vm_name}-public-ip")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = coalesce(var.nic_name, "${var.vm_name}-nic")
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = "${var.vm_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
#!/bin/bash
apt-get update
apt-get install -y docker.io git
systemctl enable docker
systemctl start docker
git clone https://github.com/docker/getting-started-app.git
cd getting-started-app
# Создаём новый Dockerfile
cat > Dockerfile << 'DOCKERFILE'
FROM node:lts-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
EXPOSE 3000
DOCKERFILE
# Собираем и запускаем контейнер
docker build -t node-app .
docker run -d -p 3000:3000 node-app
EOF
  )
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "public_ip_address" {
  value = azurerm_public_ip.public.ip_address
}

output "private_ip_address" {
  value = azurerm_network_interface.nic.private_ip_address
}
