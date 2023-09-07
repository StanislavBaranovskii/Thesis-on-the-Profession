resource "yandex_compute_instance" "vm_web_1" {
  name                      = "vm-web1"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = var.vm_web_1.zone
  hostname                  = var.vm_web_1.hostname

  resources {
    cores          = var.vm_web_1.cores
    memory         = var.vm_web_1.memory
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_web_1.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subn_a.id}"
    ip_address  = var.vm_web_1.internal_ip
    nat         = true
    dns_record {
      fqdn         = "${var.vm_web_1.hostname}.example.ru."
      dns_zone_id  = "${yandex_dns_zone.my_dns_zone.id}"
      ptr          = true
    }
  }
  
  scheduling_policy {
    preemptible = true
  }
  

  metadata = {
    ssh-keys    = var.user_metadata.ssh-keys
    user-data   = var.user_metadata.user-data
  }
}

resource "yandex_compute_instance" "vm_web_2" {
  name                      = "vm-web2"
  allow_stopping_for_update = true
  platform_id               = "standard-v1"
  zone                      = var.vm_web_2.zone
  hostname                  = var.vm_web_2.hostname

  resources {
    cores          = var.vm_web_2.cores
    memory         = var.vm_web_2.memory
    core_fraction  = 20
  }

  boot_disk {
    disk_id     = "${yandex_compute_disk.disk_web_2.id}"
  }
  
  network_interface {
    subnet_id   = "${yandex_vpc_subnet.subn_b.id}"
    ip_address  = var.vm_web_2.internal_ip
    nat         = true
    dns_record {
      fqdn         = "${var.vm_web_2.hostname}.example.ru."
      dns_zone_id  = "${yandex_dns_zone.my_dns_zone.id}"
      ptr          = true
    }
  }
  
  scheduling_policy {
    preemptible = true
  }
  

  metadata = {
    ssh-keys    = var.user_metadata.ssh-keys
    user-data   = var.user_metadata.user-data
  }
}
