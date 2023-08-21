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
    nat         = false
    security_group_ids  = ["${yandex_vpc_security_group.sg_elastic.id}"]
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: yc-user\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIERNr0N5ErxpchHSDIj/sUiDBrmEzqVDA3CT4vNjb0U5 baranovskii@baranovskyiiTravelMate"
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
    security_group_ids  = ["${yandex_vpc_security_group.sg_kibana.id}"]
  }
  
  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys    = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
    user-data   = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: yc-user\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIERNr0N5ErxpchHSDIj/sUiDBrmEzqVDA3CT4vNjb0U5 baranovskii@baranovskyiiTravelMate"
  }
}
