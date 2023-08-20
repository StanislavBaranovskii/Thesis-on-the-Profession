resource "yandex_compute_instance" "vm_prometheus" {
  name                      = "vm-prometheus"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "debian-vm-prometheus"

  resources {
    cores          = 2
    memory         = 2
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_prometheus.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet_a.id}"
    ip_address  = "10.128.0.21"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "vm_grafana" {
  name                      = "vm-grafana"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "debian-vm-grafana"

  resources {
    cores          = 2
    memory         = 2
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_grafana.id}"
  }
  
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet_a.id}"
    ip_address  = "10.128.0.22"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
  }
}
