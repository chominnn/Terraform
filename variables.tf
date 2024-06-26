variable "domain" {
  description = "The domain/host name of the zone"
  type        = string
  default     = "mylab.br"
}

variable "number_of_vms" {
  description = "The number of VMs to create"
  type        = number
  default = 6
}

variable "vm_name" {
  description = "The VM name, that's the libvirt domain name"
  type        = list(string)
  default     = ["master01","master02","master03","worker01","worker02","Haproxy"]
}

variable "ssh_port" {
  description = "The sshd port of the VM"
  type        = number
  default     = 22
}

variable "net_prefix" {
  description = "The VM network address will be net_prefix.0/24"
  default     = "211.39.158"
}

variable "IP_addr" {
  description = "Last byte about mac & iP address for this VM"
  type        = list(number)
  default     = [195,196,197,198,199,200]
}

variable "vm_memory" {
  description = "The VM memory in MegaByte"
  type        = list(number)
  default     = [2048,2048,2048,8192,8192,2048]
}

variable "vm_vcpu" {
  description = "VM vCPUs number"
  type        = list(number)
  default     = [2,2,2,6,6,1]
}

variable "source_img_url" {
  description = "The source image url"
  type        = string
  default     = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
}

variable "user_data" {
  description = "Yaml template with cloud configuration"
  type        = string
  default     = "user-data-ubuntu.yml"
}

variable "bootvol_size" {
  description = "VM boot volume size in GB"
  type        = list(number)
  # 10G
  default     = [10,10,10,100,100,10]
}

variable "datavol_size" {
  description = "VM data volume size in GB"
  type        = list(number)
  # 1G
  default     = [1,1,1,1,1,1]
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  description = "SSH user name"
  type        = string
  default     = "chomin"
}

variable "os_img" {
  description = "OS image file"
  type        = string
  default     = "focal-server-cloudimg-amd64.qcow2"
}
