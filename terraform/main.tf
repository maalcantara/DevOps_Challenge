terraform {
  backend "azurerm" {
    resource_group_name   = "rg_DesafioDevOps_backend"
    storage_account_name  = "sadesafiodevops"
    container_name        = "conteinerdesafiodevops"
    key                   = "terraform.tfstate"
  }

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

resource "azurerm_resource_group" "rg_DesafioDevOps" {
  name     = "rg_DesafioDevOps"
  location = var.resource_location
}

# Virtual Network
resource "azurerm_virtual_network" "res-5" {
  address_space       = ["10.0.0.0/16"]
  name                = "vNET_DesafioDevOps"
  location            = azurerm_resource_group.rg_DesafioDevOps.location
  resource_group_name = azurerm_resource_group.rg_DesafioDevOps.name
}

# Subnet 1
resource "azurerm_subnet" "res-6" {
  address_prefixes    = ["10.0.1.0/26"]
  name                = "subnet1_DesafioDevOps"
  resource_group_name = azurerm_resource_group.rg_DesafioDevOps.name
  virtual_network_name = azurerm_virtual_network.res-5.name
}

# Subnet 2
resource "azurerm_subnet" "res-7" {
  address_prefixes    = ["10.0.2.0/24"]
  name                = "subNET_DesafioDevOps"
  resource_group_name = azurerm_resource_group.rg_DesafioDevOps.name
  virtual_network_name = azurerm_virtual_network.res-5.name
}

# Cluster AKS
resource "azurerm_kubernetes_cluster" "res-1" {
  name                      = "cluster_DesafioDevOps"
  automatic_channel_upgrade = "patch"
  dns_prefix                = "k8s-devops"
  location                  = azurerm_resource_group.rg_DesafioDevOps.location
  resource_group_name       = azurerm_resource_group.rg_DesafioDevOps.name

  default_node_pool {
    name      = "agentpool"
    vm_size   = "Standard_DS2_v2"
    node_count = 2
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
  }
}

# ACR e seu Role Assignment
resource "azurerm_container_registry" "acrdesafiodevops1" {
  name                = "acrdesafiodevops1"
  location            = azurerm_resource_group.rg_DesafioDevOps.location
  resource_group_name = azurerm_resource_group.rg_DesafioDevOps.name
  sku                 = "Standard"
  admin_enabled       = true  # habilitando autenticação básica
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id              = azurerm_kubernetes_cluster.res-1.identity[0].principal_id
  role_definition_name      = "AcrPull"
  scope                     = azurerm_container_registry.acrdesafiodevops1.id
}