resource "yandex_vpc_security_group" "sg_web" {
  name                 = "sg-web"
  description          = "SG для WEB"
  network_id           = "${yandex_vpc_network.default.id}"

  ingress {
    protocol           = "TCP"
    description        = "in web server"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 80
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.vm_grafana.network_interface[0].ip_address}/32"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal to metrics node-exporter"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16"]
    port               = 9100
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal to metrics nginxlog-exporter"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16"]
    port               = 4040
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

  
  depends_on = [
     yandex_compute_instance.vm_grafana,
  ]
}


resource "yandex_vpc_security_group" "sg_prometheus" {
  name                 = "sg-prometheus"
  description          = "SG для Prometheus"
  network_id           = "${yandex_vpc_network.default.id}"

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.vm_grafana.network_interface[0].ip_address}/32"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to Prometheus"
    v4_cidr_blocks     = ["10.128.0.0/16"]
    port               = 9090
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Node Exporter from Prometheus"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16"]
    port               = 9100
  }

  egress {
    protocol           = "TCP"
    description        = "to internal Nginx Log Exporter from Prometheus"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16"]
    port               = 4040
  }
  
  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["10.128.0.0/16"]
    port               = 9200
  }
  
  depends_on = [
     yandex_compute_instance.vm_grafana,
  ]
}


resource "yandex_vpc_security_group" "sg_grafana" {
  name                 = "sg-grafana"
  description          = "SG для Grafana + Bastion Host"
  network_id           = "${yandex_vpc_network.default.id}"

  ingress {
    protocol           = "TCP"
    description        = "in Grafana SSH"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "in Grafana GUI"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 3000
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Prometheus from Grafana"
    v4_cidr_blocks     = ["10.128.0.0/16"]
    port               = 9090
  }

  egress {
    protocol           = "TCP"
    description        = "to internal VM SSH from Grafana"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16", "10.130.0.0/16"]
    port               = 22
  }
  
  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["10.128.0.0/16"]
    port               = 9200
  }
}


resource "yandex_vpc_security_group" "sg_elastic" {
  name                 = "sg-elastic"
  description          = "SG для Elasticsearch"
  network_id           = "${yandex_vpc_network.default.id}"

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.vm_grafana.network_interface[0].ip_address}/32"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "from internal to Elasticsearc"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16"]
    port               = 9200
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Kibana from Elasticsearch"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16"]
    port               = 5601
  }
  
  depends_on = [
     yandex_compute_instance.vm_grafana,
  ]
}


resource "yandex_vpc_security_group" "sg_kibana" {
  name                 = "sg-kibana"
  description          = "SG для Kibana"
  network_id           = "${yandex_vpc_network.default.id}"

  ingress {
    protocol           = "TCP"
    description        = "from internal Grafana to SSH"
    v4_cidr_blocks     = ["${yandex_compute_instance.vm_grafana.network_interface[0].ip_address}/32"]
    port               = 22
  }

  ingress {
    protocol           = "TCP"
    description        = "in Kibana GUI"
    v4_cidr_blocks     = ["0.0.0.0/0"]
    port               = 5601
  }


  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Kibana"
    v4_cidr_blocks     = ["10.128.0.0/16", "10.129.0.0/16"]
    port               = 9200
  }
  
  egress {
    protocol           = "TCP"
    description        = "to internal Elasticsearch from Filebeat"
    v4_cidr_blocks     = ["10.128.0.0/16"]
    port               = 9200
  }
  
  depends_on = [
     yandex_compute_instance.vm_grafana,
  ]
}
