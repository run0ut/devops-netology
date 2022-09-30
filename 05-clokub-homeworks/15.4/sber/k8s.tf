################################################################################
# Kubernetes кластер

resource "sbercloud_cce_cluster" "n15" {
  name                   = "n15-4"
  cluster_type           = "VirtualMachine"
  flavor_id              = "cce.s1.small"
  vpc_id                 = sbercloud_vpc.n15.id
  subnet_id              = sbercloud_vpc_subnet.public.id
  container_network_type = "overlay_l2"
  #   eip                    = sbercloud_vpc_eip.k8s.id # "eip" must contain a valid network IP address,
  eip        = sbercloud_vpc_eip.k8s.address
  delete_all = true
}

################################################################################
# Пул рабочих нод

resource "sbercloud_cce_node_pool" "n15-4" {
  cluster_id         = sbercloud_cce_cluster.n15.id
  name               = "n15-4"
  os                 = "CentOS 7.6"
  initial_node_count = 2
  flavor_id          = "c6.large.2"
  availability_zone  = "ru-moscow-1a"
  key_pair           = sbercloud_compute_keypair.id_rsa_n15.id
  scall_enable       = false
  priority           = 0
  type               = "vm"

  root_volume {
    size       = 50
    volumetype = "SSD"
  }
  data_volumes {
    size       = 100
    volumetype = "SSD"
  }
}
