resource "yandex_dns_zone" "my_dns_zone" {
  name        = "my-private-zone"
  description = "Моя приватная DNS зона"

  public           = false
  private_networks = [yandex_vpc_network.default.id]
}

resource "yandex_dns_recordset" "dns_rs1" {
  zone_id = yandex_dns_zone.my_dns_zone.id
  name    = "dnssrv1.example.ru."
  type    = "A"
  ttl     = 200
  data    = ["10.1.0.1"]
}

resource "yandex_dns_recordset" "dns_rs2" {
  zone_id = yandex_dns_zone.my_dns_zone.id
  name    = "dnssrv2"
  type    = "A"
  ttl     = 200
  data    = ["10.1.0.2"]
}
