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
    initialize_params {
      image_id = "debian-11"
    }
  }
  
  local_disk {
    size_bytes  = 3221225472
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.foo.id}"
    ip_address  = "10.128.0.11"
    subnet_id = "${yandex_vpc_subnet.subnet_a.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_vpc_network" "default" {
  name = "default"
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "default-ru-central1-a"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["10.128.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet_b" {
  name           = "default-ru-central1-b"
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["10.129.0.0/24"]
}


