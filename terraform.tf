terraform {
  required_providers {
      azurerm={
          source = "hashicorp/azurerm"
          version = ">= 2.38.0"
      }
  }
}

provider "azurerm" {
  subscription_id = "7977b327-7f32-47fa-aeca-ff7631a375be"
  features {}
}

resource "azurerm_resource_group" "r4" {
  name = "westus2-mc-revolution4"
  location = "West US 2"
}

