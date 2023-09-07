resource "yandex_compute_disk" "disk_web_1" {
  name     = "disk-web1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = 3
}


resource "yandex_compute_disk" "disk_web_2" {
  name     = "disk-web2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = 3
}


resource "yandex_compute_disk" "disk_elastic" {
  name     = "disk-elastic"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = 8
}


resource "yandex_compute_disk" "disk_kibana" {
  name     = "disk-kibana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = 8
}


resource "yandex_compute_disk" "disk_prometheus" {
  name     = "disk-prometheus"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = 6
}


resource "yandex_compute_disk" "disk_grafana" {
  name     = "disk-grafana"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = 6
}

