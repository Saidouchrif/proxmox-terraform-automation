terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

#################################################
# Proxmox Provider
#################################################

provider "proxmox" {
  endpoint = var.pm_api_url
  insecure = true

  api_token = "${var.pm_api_token_id}=${var.pm_api_token_secret}"
}

#################################################
# LXC Container
#################################################

resource "proxmox_virtual_environment_container" "ubuntu_lxc" {

  node_name = var.target_node
  vm_id     = 101
  started   = true

  operating_system {
    template_file_id = var.ct_template
    type             = "ubuntu"
  }

  initialization {

    hostname = var.ct_name

    ip_config {
      ipv4 {
        address = "192.168.33.50/24"
        gateway = "192.168.33.1"
      }
    }

    user_account {
      password = var.ct_password
      keys     = [file("C:/Users/saido/.ssh/id_ed25519.pub")]
    }

  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  cpu {
    cores = var.ct_cores
  }

  memory {
    dedicated = var.ct_memory
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = var.ct_disk
  }

  features {
    nesting = true
  }

  unprivileged = true
}

#################################################
# Setup container
#################################################

resource "null_resource" "setup_container" {

  depends_on = [
    proxmox_virtual_environment_container.ubuntu_lxc
  ]

  #################################################
  # Upload setup.sh
  #################################################

  provisioner "file" {

    source      = "scripts/setup.sh"
    destination = "/root/setup.sh"

    connection {
      type        = "ssh"
      host        = "192.168.33.50"
      user        = "root"
      private_key = file("C:/Users/saido/.ssh/id_ed25519")
    }

  }

  #################################################
  # Execute setup script
  #################################################

  provisioner "remote-exec" {

    inline = [

      "echo Waiting container...",
      "sleep 40",

      "chmod +x /root/setup.sh",

      "bash /root/setup.sh"

    ]

    connection {
      type        = "ssh"
      host        = "192.168.33.50"
      user        = "root"
      private_key = file("C:/Users/saido/.ssh/id_ed25519")
    }

  }

}