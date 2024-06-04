terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

#resource "libvirt_volume" "ubuntu_img" {
#  name   = "ubuntu-20.04"
#  source = "/home/ubuntu/ubuntu-20.04-server-cloudimg-amd64.img" # 로컬 파일 경로로 변경
#  format = "qcow2"
#}

resource "libvirt_domain" "ubuntu" {
  count = var.number_of_vms
  name  = var.vm_name[count.index]
  memory = var.vm_memory[count.index]
  vcpu   = var.vm_vcpu[count.index]
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.cloud-init[count.index].id

  provisioner "remote-exec" {
    inline = [
    "sudo apt-get update",
    "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
    "sudo systemctl start docker",
    "sudo systemctl enable docker"
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      password = "ubuntu"
      host     = "${var.net_prefix}.${var.IP_addr[count.index]}"
    }
  }

  network_interface {
    network_name = "br0"
    addresses    = ["${var.net_prefix}.${var.IP_addr[count.index]}"]
    bridge       = "br0"
  }

  disk {
    volume_id = element(libvirt_volume.vm-boot-vol.*.id, count.index)
  }

  disk {
    volume_id = element(libvirt_volume.vm-data-vol.*.id, count.index)
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
  }
}

