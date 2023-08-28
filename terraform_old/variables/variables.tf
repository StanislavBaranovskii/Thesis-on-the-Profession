variable "subnet_a" {
  type = list(object({
    zone_name        = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      zone_name    = "ru-central1-a"
      cidr_blocks  = ["10.128.0.0/24"]
    }
  ]
}

variable "subnet_b" {
  type = list(object({
    zone_name        = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      zone_name    = "ru-central1-b"
      cidr_blocks  = ["10.129.0.0/24"]
    }
  ]
}

variable "subnet_c" {
  type = list(object({
    zone_name        = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      zone_name    = "ru-central1-c"
      cidr_blocks  = ["10.130.0.0/24"]
    }
  ]
}

variable "cidr_blocks_z_a" {
  type    = list(string)
  default = ["10.128.0.0/24"]
}

variable "cidr_blocks_z_b" {
  type    = list(string)
  default = ["10.129.0.0/24"]
}

variable "cidr_blocks_z_c" {
  type    = list(string)
  default = ["10.130.0.0/24"]
}




variable "vm" {
 type = map(object({
    zone        = string
    hostname    = string
    internal_ip = string
 }))
 default = {
   "web-server-1" = {
      zone         = "ru-central1-a"
      hostname     = "vm-web1"
      internal_ip  = "192.168.28.51"
   }
   "web-server-2" = {
      zone         = "ru-central1-b"
      hostname     = "vm-web2"
      internal_ip  = "192.168.29.51"
   }
 }
}



