resource "yandex_compute_instance" "vm-1" {

  name                      = "linux-vm"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "<зона_доступности>"

  resources {
    cores  = "<количество ядер vCPU>"
    memory = "<объем_RAM_в_ГБ>"
  }

  boot_disk {
    initialize_params {
      image_id = "<идентификатор_образа>"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  metadata = {
    ssh-keys = "<имя_пользователя>:<содержимое_SSH-ключа>"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "<зона_доступности>"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

