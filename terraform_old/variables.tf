variable "subnet_a" {
  description         = "Имя и IP подсети A"
  type = list(object({
    zone_name         = string
    cidr_blocks       = list(string)
  }))
  default = [
    {
      zone_name       = "ru-central1-a"
      cidr_blocks     = ["10.128.0.0/24"]
    }
  ]
}

variable "subnet_b" {
  description         = "Имя и IP подсети B"
  type = list(object({
    zone_name         = string
    cidr_blocks       = list(string)
  }))
  default = [
    {
      zone_name       = "ru-central1-b"
      cidr_blocks     = ["10.129.0.0/24"]
    }
  ]
}

variable "subnet_c" {
  description         = "Имя и IP подсети C"
  type = list(object({
    zone_name         = string
    cidr_blocks       = list(string)
  }))
  default = [
    {
      zone_name       = "ru-central1-c"
      cidr_blocks     = ["10.130.0.0/24"]
    }
  ]
}



variable "cidr_blocks_z_a" {
  description         = "IP адреса подсети A"
  type                = list(string)
  default             = ["10.128.0.0/24"]
}

variable "cidr_blocks_z_b" {
  description         = "IP адреса подсети B"
  type                = list(string)
  default             = ["10.129.0.0/24"]
}

variable "cidr_blocks_z_c" {
  description         = "IP адреса подсети C"
  type                = list(string)
  default             = ["10.130.0.0/24"]
}



variable "vm_web_1" {
 type = map(object({
    zone              = string
    hostname          = string
    internal_ip       = string
    cores             = number
    memory            = number
    disk_size         = number
 }))
 default = [
    {  
      zone            = "ru-central1-a"
      hostname        = "vm-web1"
      internal_ip     = "10.128.0.11"
      cores           = 2
      memory          = 1
      disk_size       = 3
    }
  ]
}

variable "vm_web_2" {
 type = map(object({
    zone              = string
    hostname          = string
    internal_ip       = string
    cores             = number
    memory            = number
    disk_size         = number
 }))
 default = [
    {
      zone            = "ru-central1-b"
      hostname        = "vm-web2"
      internal_ip     = "10.129.0.11"
      cores           = 2
      memory          = 1
      disk_size         = 3
    }
  ]
}


variable "user_metadata" {
 type = map(object({
    ssh-keys          = string
    user-data         = string
 }))
 sensitive            = true
 default = [
    {  
      ssh-keys        = "yc-user:${file("~/.ssh/id_ed25519.pub")}"
      user-data       = "#cloud-config\ndatasource:\n Ec2:\n  strict_id: false\nssh_pwauth: no\nusers:\n- name: yc-user\n  sudo: ALL=(ALL) NOPASSWD:ALL\n  shell: /bin/bash\n  ssh_authorized_keys:\n  - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIERNr0N5ErxpchHSDIj/sUiDBrmEzqVDA3CT4vNjb0U5 baranovskii@baranovskyiiTravelMate"
    }
  ]
}

