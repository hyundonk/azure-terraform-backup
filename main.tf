provider "azurerm" {
    version = "2.25.0"
    features {}
}

terraform {
    backend "azurerm" {}
}
