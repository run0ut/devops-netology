################################################################################
# Autoscaling Group

resource "sbercloud_as_configuration" "n15" {
  scaling_configuration_name = "n15"
  instance_config {
    flavor = "s6.small.1"
    image  = data.sbercloud_images_image.centos.id
    disk {
      size        = 40
      volume_type = "SSD"
      disk_type   = "SYS"
    }
    key_name  = sbercloud_compute_keypair.id_rsa_n15.id
    user_data = <<EOF
#!/bin/bash
yum -y install httpd
systemctl start httpd
systemctl enable httpd.service
echo "<html><p>Autoscaling</p><p>"`cat /etc/hostname`"</p><img src="https://${sbercloud_obs_bucket.n15.bucket}.obs.ru-moscow-1.hc.sbercloud.ru/${sbercloud_obs_bucket_object.netology-logo.key}" alt="Netology logo"></html>" > /var/www/html/index.html
EOF
  }
}

resource "sbercloud_as_group" "n15" {
  scaling_group_name       = "n15"
  scaling_configuration_id = sbercloud_as_configuration.n15.id
  desire_instance_number   = 3
  min_instance_number      = 0
  max_instance_number      = 6
  vpc_id                   = sbercloud_vpc.n15.id
  delete_publicip          = true
  delete_instances         = "yes"

  networks {
    id = sbercloud_vpc_subnet.public.id
  }
  security_groups {
    id = sbercloud_networking_secgroup.n15.id
  }
  lbaas_listeners {
    pool_id       = sbercloud_lb_pool.n15.id
    protocol_port = sbercloud_lb_listener.n15.protocol_port
  }
  lbaas_listeners {
    pool_id       = sbercloud_lb_pool.n15-secure.id
    protocol_port = 80
  }
}
