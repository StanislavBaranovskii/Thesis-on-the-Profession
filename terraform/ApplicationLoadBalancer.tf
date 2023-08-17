resource "yandex_alb_target_group" "foo" {
  name           = "project-web-target-group"

  target {
    subnet_id    = "<идентификатор_подсети>"
    ip_address   = "10.128.0.11"
  }

  target {
    subnet_id    = "<идентификатор_подсети>"
    ip_address   = "10.129.0.11"
  }
}

resource "yandex_alb_backend_group" "test-backend-group" {
  name                     = "project-web-backend-group"
  session_affinity {
    connection {
      source_ip = <true_или_false>
    }
  }

  http_backend {
    name                   = "<имя_бэкенда>"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["<идентификатор_целевой_группы>"]
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

resource "yandex_alb_http_router" "tf-router" {
  name          = "<имя_HTTP-роутера>"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "<имя_виртуального_хоста>"
  http_router_id          = yandex_alb_http_router.tf-router.id
  route {
    name                  = "<имя_маршрута>"
    http_route {
      http_route_action {
        backend_group_id  = "<идентификатор_группы_бэкендов>"
        timeout           = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "test-balancer" {
  name        = "<имя_L7-балансировщика>"
  network_id  = "<идентификатор_сети>"

  allocation_policy {
    location {
      zone_id   = "<зона_доступности>"
      subnet_id = "<идентификатор_подсети>" 
    }
  }

  listener {
    name = "<имя_обработчика>"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 9000 ]
    }
    http {
      handler {
        http_router_id = "<идентификатор_HTTP-роутера>"
      }
    }
  }

  log_options {
    log_group_id = "<идентификатор_лог-группы>"
    discard_rule {
      http_codes          = ["<HTTP-код>"]
      http_code_intervals = ["<класс_HTTP-кодов>"]
      grpc_codes          = ["<gRPC-код>"]
      discard_percent     = <доля_отбрасываемых_логов>
    }
  }
}

