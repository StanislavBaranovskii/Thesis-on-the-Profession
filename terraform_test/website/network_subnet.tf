resource "yandex_vpc_network" "default" {
  name = "default"
}

resource "yandex_vpc_subnet" "subn_a" {
  name           = "${yandex_vpc_network.default.id}-${var.subnet_a.zone_name}"
  zone           = var.subnet_a.zone_name
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = var.subnet_a.cidr_blocks
}

resource "yandex_vpc_subnet" "subn_b" {
  name           = "${yandex_vpc_network.default.id}-${var.subnet_b.zone_name}"
  zone           = var.subnet_b.zone_name
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = var.subnet_b.cidr_blocks
}

