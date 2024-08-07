terraform {
  backend "local" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.99.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_DesafioDevOps_backend" {
  location = var.resource_location
  name     = "rg_DesafioDevOps_backend"
}

resource "azurerm_storage_account" "res-8" {
  name                     = "sadesafiodevops"
  resource_group_name      = azurerm_resource_group.rg_DesafioDevOps_backend.name
  location                 = azurerm_resource_group.rg_DesafioDevOps_backend.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_storage_container" "res-10" {
  name                  = "conteinerdesafiodevops"
  storage_account_name  = azurerm_storage_account.res-8.name
  container_access_type = "private"
}

# ACR e seu Role Assignment
resource "azurerm_container_registry" "acrdesafiodevops" {
  name                = "acrdesafiodevops"
  location            = azurerm_resource_group.rg_DesafioDevOps_backend.location
  resource_group_name = azurerm_resource_group.rg_DesafioDevOps_backend.name
  sku                 = "Standard"
  admin_enabled       = true  # habilitando autenticação básica
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id              = azurerm_kubernetes_cluster.res-1.identity[0].principal_id
  role_definition_name      = "AcrPull"
  scope                     = azurerm_container_registry.acrdesafiodevops.id
}