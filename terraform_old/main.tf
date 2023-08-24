resource "yandex_compute_instance" "vm_web_1" {
  name                      = "vm-web1"
  folder_id                 = "b1gadaampg6bbldf60up"
  service_account_id        = "${yandex_iam_service_account.sa_terraform.id}"
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
    mode        = "READ_WRITE"
    initialize_params {
      image_id  = "fd83u9thmahrv9lgedrk"
      size      = 3
      type      = "network-hdd"
    }
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

