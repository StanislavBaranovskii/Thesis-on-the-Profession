resource "yandex_vpc_security_group" "sg-web" {
  name        = "Test"
  description = "SG для WEB"
  network_id  = "${yandex_vpc_network.default.id}"

  ingress {
    protocol       = "TCP"
    description    = "in web server"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "from internal Grafana to SSH"
    v4_cidr_blocks = ["${yandex_compute_instance.vm_grafana.network_interface[0].ip_address}/32"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "from internal to metrics node-exporter"
    v4_cidr_blocks = ["10.128.0.0/16", "10.129.0.0/16"]
    port           = 9100
  }

  ingress {
    protocol       = "TCP"
    description    = "from internal to metrics nginxlog-exporter"
    v4_cidr_blocks = ["10.128.0.0/16", "10.129.0.0/16"]
    port           = 4040
  }

  ingress {
    protocol           = "ANY"
    description        = "loadbalancer healthchecks"
    predefined_target  = "loadbalancer_healthchecks"
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["10.128.0.0/16"]
    port               = 9200
  }

  egress {
    protocol           = "TCP"
    description        = "to internal Kibana from Filebeat"
    v4_cidr_blocks     = ["10.128.0.0/16"]
    port               = 5601
  }
  
  depends_on = [
     yandex_compute_instance.vm_grafana,
  ]
}



