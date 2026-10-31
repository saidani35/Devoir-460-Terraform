terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "MalikaSaidani-Devoir460"

    workspaces {
      name = "MalikaSaidani-Devoir460"
    }
  }
}

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "rg_cr460" {
  name     = "rg-cr460-malika"
  location = "Canada Central"
}
