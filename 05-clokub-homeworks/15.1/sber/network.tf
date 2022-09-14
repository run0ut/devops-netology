################################################################################
# VPC и сабнеты

resource "sbercloud_vpc" "n15" {
  name = "n15"
  cidr = "10.10.0.0/16"
}

resource "sbercloud_vpc_subnet" "public" {
  name       = "public"
  cidr       = "10.10.1.0/24"
  gateway_ip = "10.10.1.1"
  vpc_id     = sbercloud_vpc.n15.id
}

resource "sbercloud_vpc_subnet" "private" {
  name       = "private"
  cidr       = "10.10.2.0/24"
  gateway_ip = "10.10.2.1"
  vpc_id     = sbercloud_vpc.n15.id
}

################################################################################
# Security group и правила ICMP и SSH

resource "sbercloud_networking_secgroup" "n15" {
  name        = "n15"
  description = "main security group"
}

resource "sbercloud_networking_secgroup_rule" "allow_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  protocol          = "icmp"
  description       = "allow all ICMP traffic"
  security_group_id = sbercloud_networking_secgroup.n15.id
}

resource "sbercloud_networking_secgroup_rule" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  description       = "allow default SSH port fron any source"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup.n15.id
}

################################################################################
# Внешние IP - для public инстанса и NAT Gateway

resource "sbercloud_vpc_eip" "eip_1" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    share_type  = "PER"
    name        = "test"
    size        = 5
    charge_mode = "traffic"
  }
}

resource "sbercloud_vpc_eip" "eip_2" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    share_type  = "PER"
    name        = "test"
    size        = 5
    charge_mode = "traffic"
  }
}

################################################################################
# NAT Gateway и привязка внешнего IP

resource "sbercloud_nat_gateway" "n15" {
  name      = "n15"
  vpc_id    = sbercloud_vpc.n15.id
  subnet_id = sbercloud_vpc_subnet.private.id
  spec      = "1"
}

resource "sbercloud_nat_snat_rule" "to_nat_gateway" {
  nat_gateway_id = sbercloud_nat_gateway.n15.id
  subnet_id      = sbercloud_vpc_subnet.private.id
  floating_ip_id = sbercloud_vpc_eip.eip_2.id
}

################################################################################
# Таблица маршрутизации для private сети с маршрутом через NAT Gateway

resource "sbercloud_vpc_route_table" "private" {
  name        = "private"
  vpc_id      = sbercloud_vpc.n15.id
  subnets     = [sbercloud_vpc_subnet.private.id]
  description = "route table for private subnet"

  route {
    destination = "0.0.0.0/0"
    type        = "nat"
    nexthop     = sbercloud_nat_gateway.n15.id
  }
}