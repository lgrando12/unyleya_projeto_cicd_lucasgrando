# Configura o provedor do Azure
provider "azurerm" {
  features {}
  subscription_id = "2ac2b893-e719-4cc8-a027-b27c9ac8c0da"
}

# Define um Grupo de Recursos para organizar tudo
resource "azurerm_resource_group" "rg" {
  name     = "rg-unyleya-lucas-grando" # <--- NOME ÚNICO NA SUA CONTA
  location = "Brazil South"            # <--- LOCALIZAÇÃO CONSISTENTE
}

# 1. Cria o Azure Container Registry (ACR) para armazenar as imagens Docker
resource "azurerm_container_registry" "acr" {
  name                = "acrunyleyalucasgrando" # <--- NOME ÚNICO GLOBALMENTE
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# 2. Cria o Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-unyleya-lucas-grando"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksunyleyalucasgrando" # <--- NOME ÚNICO NA REGIÃO

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2s_v6"
  }

  identity {
    type = "SystemAssigned"
  }
}

# 3. Concede permissão para o AKS puxar imagens do ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}