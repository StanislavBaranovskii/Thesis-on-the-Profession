cidr_blocks_z_a = ["10.128.0.0/24"]


cidr_blocks_z_b = ["10.129.0.0/24"]


cidr_blocks_z_c = ["10.130.0.0/24"]


variable "vm_web1" {
  type = list(object({
    name        = string
    zone        = string
    hostname    = string
    internal_ip = string
  }))
  default = [
    {
      name         = "vm-web1"
      zone         = "ru-central1-a"
      hostname     = "debian-vm-web1"
      internal_ip  = "10.128.0.11"
    }
  ]
}

