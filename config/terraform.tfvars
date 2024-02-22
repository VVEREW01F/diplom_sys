#=========== main ==============
yandex_cloud_id  = "dn2g34hqnm6t0j08llhm"
yandex_folder_id = "b1gd90nbhjaagrfjjfel"

#=========== subnet ==============
subnets = {
  "subnets" = [
    {
      name = "subnet-1"
      zone = "ru-central1-a"
      cidr = ["192.168.10.0/24"]
    },
    {
      name = "subnet-2"
      zone = "ru-central1-b"
      cidr = ["192.168.20.0/24"]
    },
    {
      name = "subnet-3"
      zone = "ru-central1-c"
      cidr = ["192.168.30.0/24"]
    }
  ]
}