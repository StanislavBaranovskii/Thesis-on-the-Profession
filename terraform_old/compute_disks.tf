resource "yandex_compute_disk" "disk_web_1" {
  name     = "disk-web1"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = var.vm_web_1.disk_size
}


resource "yandex_compute_disk" "disk_web_2" {
  name     = "disk-web2"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  image_id = "fd83u9thmahrv9lgedrk"
  size     = var.vm_web_2.disk_size
}


