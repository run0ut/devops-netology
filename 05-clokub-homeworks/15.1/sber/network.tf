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

resource "sbercloud_network_acl_rule" "allow_all" {
  name                   = "allow-all"
  description            = "allow any traffic"
  action                 = "allow"
  protocol               = "any"
  ip_version             = 4
  source_ip_address      = "0.0.0.0/0"
  destination_ip_address = "0.0.0.0/0"
  enabled                = "true"
}

resource "sbercloud_network_acl_rule" "allow_icmp" {
  name                   = "allow-icmp"
  description            = "allow ICMP traffic"
  ip_version             = 4
  action                 = "allow"
  protocol               = "icmp"
  source_ip_address      = "0.0.0.0/0"
  destination_ip_address = "0.0.0.0/0"
  enabled                = "true"
}

resource "sbercloud_network_acl_rule" "allow_ssh" {
  name                   = "allow-ssh"
  description            = "allow default SSH port"
  ip_version             = 4
  action                 = "allow"
  protocol               = "tcp"
  source_ip_address      = "0.0.0.0/0"
  destination_ip_address = "0.0.0.0/0"
  destination_port       = "22"
  enabled                = "true"
}

resource "sbercloud_network_acl" "n15" {
  name = "n15"
  subnets = [
    sbercloud_vpc_subnet.public.id,
  sbercloud_vpc_subnet.private.id]
  inbound_rules = [
    sbercloud_network_acl_rule.allow_icmp.id,
  sbercloud_network_acl_rule.allow_ssh.id]
  outbound_rules = [sbercloud_network_acl_rule.allow_all.id]
}

resource "sbercloud_networking_secgroup" "n15" {
  name        = "n15"
  description = "main security group"
}

resource "sbercloud_networking_secgroup_rule" "allow_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = sbercloud_networking_secgroup.n15.id
}

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

resource "sbercloud_vpc_route_table" "private" {
  name        = "private"
  vpc_id      = sbercloud_vpc.n15.id
  description = "route table for private subnet"

  route {
    destination = "0.0.0.0/0"
    type        = "nat"
    nexthop     = sbercloud_nat_gateway.n15.id
  }
}