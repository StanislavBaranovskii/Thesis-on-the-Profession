terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {

  name                      = "vm-from-disks"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "<зона_доступности>"

  resources {
    cores  = <количество_ядер_vCPU>
    memory = <объем_RAM_в_ГБ>
  }

  boot_disk {
    initialize_params {
      disk_id = "<идентификатор_загрузочного_диска>"
    }
  }

  secondary_disk {
    disk_id = "<идентификатор_дополнительного_диска>"
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
  name       = "subnet1"
  zone       = "<зона_доступности>"
  network_id = "${yandex_vpc_network.network-1.id}"
}

