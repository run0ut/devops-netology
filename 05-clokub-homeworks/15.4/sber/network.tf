################################################################################
# VPC и сабнеты

resource "sbercloud_vpc" "n15" {
  name = "n15"
  cidr = "10.10.0.0/16"
}

# Public
resource "sbercloud_vpc_subnet" "public" {
  name              = "public"
  cidr              = "10.10.1.0/24"
  gateway_ip        = "10.10.1.1"
  primary_dns       = "8.8.8.8"
  vpc_id            = sbercloud_vpc.n15.id
  availability_zone = "ru-moscow-1a"
}

# Private
resource "sbercloud_vpc_subnet" "private" {
  name              = "private"
  cidr              = "10.10.2.0/24"
  gateway_ip        = "10.10.2.1"
  primary_dns       = "8.8.8.8"
  vpc_id            = sbercloud_vpc.n15.id
  availability_zone = "ru-moscow-1a"
}

resource "sbercloud_vpc_subnet" "private-b" {
  name              = "private-b"
  cidr              = "10.10.3.0/24"
  gateway_ip        = "10.10.3.1"
  primary_dns       = "8.8.8.8"
  vpc_id            = sbercloud_vpc.n15.id
  availability_zone = "ru-moscow-1b"
}

resource "sbercloud_vpc_subnet" "private-c" {
  name              = "private-c"
  cidr              = "10.10.4.0/24"
  gateway_ip        = "10.10.4.1"
  primary_dns       = "8.8.8.8"
  vpc_id            = sbercloud_vpc.n15.id
  availability_zone = "ru-moscow-1c"
}

################################################################################
# Security group и правила ICMP, HTTP и SSH

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

resource "sbercloud_networking_secgroup_rule" "allow_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  description       = "allow default HTTP port from any source"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup.n15.id
}

resource "sbercloud_networking_secgroup_rule" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  description       = "allow default SSH port from any source"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup.n15.id
}

resource "sbercloud_networking_secgroup_rule" "allow_mysql_local" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  description       = "allow default SSH port from private IPs"
  port_range_min    = 3306
  port_range_max    = 3306
  remote_ip_prefix  = "10.0.0.0/8"
  security_group_id = sbercloud_networking_secgroup.n15.id
}

################################################################################
# Внешние IP

# IP балансировщика
resource "sbercloud_vpc_eip" "lb" {
  publicip {
    type = "5_bgp"
    # type = "5_gray"
    # type = "5_elbbgp"
  }
  bandwidth {
    share_type  = "PER"
    name        = "test"
    size        = 5
    charge_mode = "traffic"
  }
}

# IP NatGateway, чтобы инстансы могли ходить в интернет
resource "sbercloud_vpc_eip" "nat" {
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

# IP кластера Kubernetes
resource "sbercloud_vpc_eip" "k8s" {
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
  subnet_id = sbercloud_vpc_subnet.public.id
  spec      = "1"
}

resource "sbercloud_nat_snat_rule" "public_to_nat_gateway" {
  nat_gateway_id = sbercloud_nat_gateway.n15.id
  subnet_id      = sbercloud_vpc_subnet.public.id
  floating_ip_id = sbercloud_vpc_eip.nat.id
}

resource "sbercloud_nat_snat_rule" "private_to_nat_gateway" {
  nat_gateway_id = sbercloud_nat_gateway.n15.id
  subnet_id      = sbercloud_vpc_subnet.private.id
  floating_ip_id = sbercloud_vpc_eip.nat.id
}
