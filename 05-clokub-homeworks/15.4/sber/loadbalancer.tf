################################################################################
# ELastic Load Balancer, балансировщик нагрузки

# Балансировщик
resource "sbercloud_lb_loadbalancer" "n15" {
  name          = "n15"
  vip_subnet_id = sbercloud_vpc_subnet.public.subnet_id
}

# Внешний IP балансировщика
resource "sbercloud_networking_eip_associate" "elb_eip_associate" {
  public_ip = sbercloud_vpc_eip.lb.address
  port_id   = sbercloud_lb_loadbalancer.n15.vip_port_id
}
