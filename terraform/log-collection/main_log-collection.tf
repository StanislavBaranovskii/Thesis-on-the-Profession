resource "yandex_compute_instance" "vm_elastic" {
  name                      = "vm-elastic"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "debian-vm-elastic"

  resources {
    cores          = 2
    memory         = 4
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_elastic.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet_a.id}"
    ip_address  = "10.128.0.31"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "vm_kibana" {
  name                      = "vm-kibana"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "debian-vm-kibana"

  resources {
    cores          = 2
    memory         = 4
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_kibana.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet_a.id}"
    ip_address  = "10.128.0.32"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
  }
}
