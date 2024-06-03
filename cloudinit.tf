data "template_file" "user_data" {
  template = file(var.user_data)
  count = var.number_of_vms
  vars = {
    hostname        = var.vm_name[count.index]
    sshdport        = var.ssh_port
    ssh_public_key  = file(var.ssh_public_key)
    ssh_user        = var.ssh_user
    net_prefix      = var.net_prefix
    IP_addr         = tostring(var.IP_addr[count.index])

  }
}

resource "libvirt_cloudinit_disk" "cloud-init" {
  name = format("cloud-init%03d.iso", count.index)
  count = var.number_of_vms
  pool = "iso"
  user_data      = data.template_file.user_data[count.index].rendered
}

