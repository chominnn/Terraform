resource "libvirt_volume" "source-img" {
  name = "source-im"
  pool = "vm"
  source = var.source_img_url
  format = "qcow2"
}

resource "libvirt_volume" "vm-boot-vol" {
  count          = var.number_of_vms
  name           = join(".", [replace("${var.vm_name[count.index]}-${var.domain}-vol",".","_"),"qcow2"])
  pool           = "vm"
  base_volume_id = libvirt_volume.source-img.id
  size           = var.bootvol_size[count.index] * 1024 * 1024 * 1024
}

resource "libvirt_volume" "vm-data-vol" {
  count          = var.number_of_vms
  name           = join(".", [replace("${var.vm_name[count.index]}-${var.domain}-datavol",".","_"),"qcow2"])
  pool           = "vm"
  size           = var.datavol_size[count.index] * 1024 * 1024 * 1024
}
