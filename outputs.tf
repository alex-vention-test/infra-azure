output "resource_group_name" {
  value = module.resource_group.name
}

output "vm_public_ip" {
  value = module.virtual_machine.public_ip_address
}

output "vm_private_ip" {
  value = module.virtual_machine.private_ip_address
}
