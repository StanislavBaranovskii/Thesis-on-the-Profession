resource "yandex_compute_instance" "vm_web_1" {
  name                      = "vm-web1"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-a"
  hostname                  = "debian-vm-web1"

  resources {
    cores          = 2
    memory         = 1
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_web_1.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet_a.id}"
    ip_address  = "10.128.0.11"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "vm_web_2" {
  name                      = "vm-web2"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = "ru-central1-b"
  hostname                  = "debian-vm-web2"

  resources {
    cores          = 2
    memory         = 1
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_web_2.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subnet_b.id}"
    ip_address  = "10.129.0.11"
    nat         = true
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
  }
}
