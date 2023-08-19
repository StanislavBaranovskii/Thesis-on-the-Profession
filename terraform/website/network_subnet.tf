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

resource "yandex_vpc_subnet" "subnet_c" {
  name           = "default-ru-central1-c"
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["10.130.0.0/24"]
}

