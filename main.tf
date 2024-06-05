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
    # Docker 설치
    "sudo apt-get update",
    "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
    "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
    "sudo apt-get update",
    "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
    "sudo systemctl start docker",
    "sudo systemctl enable docker",

    # containerd 적용
    "sudo mkdir -p /etc/containerd",
    "containerd config default | sudo tee /etc/containerd/config.toml > /dev/null",
    "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml",
    "sudo systemctl restart containerd",

    # Kubernetes 설치
    "swapoff --all",
    "sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl",
    "sudo mkdir -p /etc/apt/keyrings",
    "sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
    "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
    "sudo apt-get update",
    "sudo apt-get install -y kubelet kubeadm kubectl",
    "sudo apt-mark hold kubelet kubeadm kubectl",

    # kubelet 시작 및 활성화
    "sudo systemctl start kubelet",
    "sudo systemctl enable kubelet",

    # kubeadm 인증서 추가
    "sudo sed -i '/disabled_plugins/s/^/#/' /etc/containerd/config.toml",
    "sudo systemctl restart containerd",
    "sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock",

    # kub-config.yaml 파일 생성
    "echo '---' | sudo tee /home/ubuntu/kub-config.yaml",
    "echo 'apiVersion: \"kubeadm.k8s.io/v1beta3\"' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'kind: InitConfiguration' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'nodeRegistration:' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo '  criSocket: \"unix:///var/run/containerd/containerd.sock\"' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo '---' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'apiVersion: kubelet.config.k8s.io/v1beta1' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'kind: KubeletConfiguration' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'failSwapOn: false' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'featureGates:' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo '  NodeSwap: true' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'memorySwap:' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo '  swapBehavior: LimitedSwap' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo '---' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'apiVersion: kubeadm.k8s.io/v1beta3' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'kind: ClusterConfiguration' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo 'networking:' | sudo tee -a /home/ubuntu/kub-config.yaml",
    "echo '  podSubnet: \"172.24.0.0/24\" # --pod-network-cidr' | sudo tee -a /home/ubuntu/kub-config.yaml",
    

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

