resource "yandex_alb_target_group" "my_target_group" {
  name           = "project-web-target-group"
  description    = "ALB:Целевая группа"
  target {
    subnet_id    = yandex_vpc_subnet.subnet_a.id
    ip_address   = yandex_compute_instance.vm_web_1.network_interface.ip_address
  }

  target {
    subnet_id    = yandex_vpc_subnet.subnet_b.id
    ip_address   = yandex_compute_instance.vm_web_2.network_interface.ip_address
  }
  
  depends_on = [
     yandex_compute_instance.vm_web_1,
     yandex_compute_instance.vm_web_2,
  ]
}


resource "yandex_alb_backend_group" "my_backend_group" {
  name                     = "project-web-backend-group"
  description              = "ALB:Группа бэкендов"
  http_backend {
    name                   = "project-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.my_target_group.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}


resource "yandex_alb_http_router" "my_http_router" {
  name          = "project-http-router"
  description   = "ALB:HTTP роутер"
}

resource "yandex_alb_virtual_host" "my_virtual_host" {
  name                    = "project-vhost"
  http_router_id          = ["${yandex_alb_http_router.my_http_router.id}"]
  route {
    name                  = "project-route"
    http_route {
      http_route_action {
        backend_group_id  = ["${yandex_alb_backend_group.my_backend_group.id}"]
        timeout           = "60s"
      }
    }
  }
}


resource "yandex_alb_load_balancer" "my_alb" {
  name        = "project-alb"
  description = "ALB"
  network_id  = "${yandex_vpc_network.default.id}"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet_a.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet_b.id
    }
  }

  listener {
    name = "my_listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.my_http_router.id
      }
    }
  }
}

