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

resource "libvirt_volume" "ubuntu_img" {
  name   = "ubuntu-20.04"
  source = "/home/ubuntu/ubuntu-20.04-server-cloudimg-amd64.img" # 로컬 파일 경로로 변경
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data-ubuntu.yml")
}

resource "libvirt_domain" "ubuntu" {
  name        = "ubuntu-kvm"
  memory      = 2048
  vcpu        = 2
  qemu_agent  = true
  cloudinit   = libvirt_cloudinit_disk.commoninit.id
  
  network_interface {
    network_name = "br0"
    addresses = ["211.39.158.195/24"]
    bridge    = "br0"
  }

  disk {
    volume_id = libvirt_volume.ubuntu_img.id
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

