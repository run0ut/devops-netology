################################################################################
# ELastic Load Balancer, балансировщик нагрузки

# Балансировщик
resource "sbercloud_lb_loadbalancer" "n15" {
  name          = "loadbalancer_1"
  vip_subnet_id = sbercloud_vpc_subnet.public.subnet_id
}

# Внешний IP балансировщика
resource "sbercloud_networking_eip_associate" "elb_eip_associate" {
  public_ip = sbercloud_vpc_eip.lb.address
  port_id   = sbercloud_lb_loadbalancer.n15.vip_port_id
}

################################################################################
# HTTP

# Листенер на порт HTTP
resource "sbercloud_lb_listener" "n15" {
  name            = "n15"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = sbercloud_lb_loadbalancer.n15.id
}

# Группа хостов (backend group)
resource "sbercloud_lb_pool" "n15" {
  name        = "n15"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.n15.id
}

# Настройка мониторинга
resource "sbercloud_lb_monitor" "monitor_1" {
  pool_id     = sbercloud_lb_pool.n15.id
  type        = "HTTP"
  url_path    = "/"
  delay       = 3
  timeout     = 2
  max_retries = 2
}

################################################################################
# HTTPS

# Сертификат
resource "sbercloud_lb_certificate" "n15" {
  name        = "certificate_1"
  description = "terraform test certificate"
  domain      = "www.elb.com"
  private_key = file("cert/privkey.pem")
  certificate = file("cert/cert.pem")

  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

# Листенер на порт HTTPS
resource "sbercloud_lb_listener" "n15-secure" {
  name            = "n15-secure"
  protocol        = "TERMINATED_HTTPS"
  protocol_port   = 443
  loadbalancer_id = sbercloud_lb_loadbalancer.n15.id
  default_tls_container_ref  = sbercloud_lb_certificate.n15.id
}

# Группа инстансов
resource "sbercloud_lb_pool" "n15-secure" {
  name        = "n15-secure"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = sbercloud_lb_listener.n15-secure.id
}

# Настройка мониторинга
resource "sbercloud_lb_monitor" "monitor_https" {
  pool_id     = sbercloud_lb_pool.n15-secure.id
  type        = "HTTP"
  url_path    = "/"
  delay       = 3
  timeout     = 2
  max_retries = 2
}