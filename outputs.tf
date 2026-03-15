output "container_name" {
  value = proxmox_virtual_environment_container.ubuntu_lxc.initialization[0].hostname
}

output "container_ip" {
  value = "192.168.33.50"
}