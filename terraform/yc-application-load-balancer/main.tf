resource "yandex_alb_target_group" "my_target_group" {
  name           = "project-web-target-group"

  target {
    subnet_id    = "e9bqljipn6j8foodb1hu"
    ip_address   = "10.128.0.11"
  }

  target {
    subnet_id    = "e2li9rrat8kff41b4vs2"
    ip_address   = "10.129.0.11"
  }
}


resource "yandex_alb_backend_group" "my_backend_group" {
  name                     = "project-web-backend-group"

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
  network_id  = "enpv8bp9rhrhc97bnfv2"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "e9bqljipn6j8foodb1hu" 
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = "e2li9rrat8kff41b4vs2" 
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

