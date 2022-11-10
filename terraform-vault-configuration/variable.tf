
variable "base_path" {
    type    = string 
    default = "rc3labs"
}

variable "ca_name" {
  type = string
  description = "Name of the CA to create"
}

variable "description" {
  type = string
  description = "Description of the CA to create"
  default = "rc3labs internal CA" 
}

variable "default_lease" {
  type = number
  description = "Default lease time"
  # 12 hours
  default = 8760
}

variable "maximum_lease" {
  type = number
  description = "Maximum lease time"
  # 24 hours
  default = 8760
}

variable "crl_time" {
  type = string
  description = "Time a CRL will be valid"
  default = "86400s"
}

variable "pki_aia_basepath" {
  type = string
  description = "CA and CRL public access base path"
  default = "https://vault-pki.rc3labs.org"
}

