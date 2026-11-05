# Localisation et conventions
variable "location" {
  type = string
}

variable "prefix" {
  type = string
}

variable "ARM_SUBSCRIPTION_ID" {
  type = string
}

# Paramètres VM
variable "computer_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}
variable "vm_size" {
  type = string
}
variable "resource_group_name" {
  type = string
}
