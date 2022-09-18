################################################################################
# VPC и сабнеты

resource "yandex_vpc_network" "network" {
  name = "network-netology-15"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = yandex_vpc_network.network.id
}

################################################################################
# Network Load Balancer

resource "yandex_lb_network_load_balancer" "n15-net-lb" {
  name = "n15-net-lb"

  listener {
    name = "n15-net-lb"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.n15-net-lb.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

################################################################################
# Application Load Balancer

resource "yandex_alb_http_router" "n15-app-lb" {
  name = "n15-app-lb"
  labels = {
    tf-label    = "n15-app-lb"
    empty-label = ""
  }
}

resource "yandex_alb_backend_group" "n15-app-lb" {
  name      = "n15-app-lb"

  http_backend {
    name = "test-http-backend"
    weight = 1
    port = 80
    target_group_ids = [yandex_compute_instance_group.n15-app-lb.application_load_balancer[0].target_group_id]
    # tls {
    #   sni = "backend-domain.internal"
    # }
    load_balancing_config {
      panic_threshold = 5
    }    
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
    http2 = "false"
  }
}

resource "yandex_alb_load_balancer" "n15-app-lb" {
  name = "n15-app-lb"

  network_id = yandex_vpc_network.network.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "n15-app-lb"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.n15-app-lb.id
      }
    }
  }
}

resource "yandex_alb_virtual_host" "n15-app-lb" {
  name      = "n15-app-lb"
  http_router_id = yandex_alb_http_router.n15-app-lb.id
  route {
    name = "http"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.n15-app-lb.id
        timeout = "3s"
      }
    }
  }
}