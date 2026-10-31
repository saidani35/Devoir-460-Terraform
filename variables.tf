# Localisation et conventions
variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

# Identifiants Azure
variable "ARM_CLIENT_ID" {
  type = string
}

variable "ARM_CLIENT_SECRET" {
  type      = string
  sensitive = true
}

variable "ARM_TENANT_ID" {
  type = string
}

variable "ARM_SUBSCRIPTION_ID" {
  type = string
}


variable "admin_password" {
  type      = string
  sensitive = true
}
