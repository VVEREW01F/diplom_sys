#=========== main ==============

variable "yandex_cloud_id" {
  description = "The cloud ID"
  type        = string
}
variable "yandex_folder_id" {
  description = "The folder ID"
  type        = string
}
variable "default_zone" {
  description = "The default zone"
  type        = string
  default     = "ru-cenral1-a"
}


#=========== subnet ==============
variable "subnets" {
  description = "Subnets for www cluster"

  type = map(list(object(
    {
      name = string,
      zone = string,
      cidr = list(string)
    }))
  )
}
