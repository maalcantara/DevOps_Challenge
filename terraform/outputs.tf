# Outputs para usar no pipeline
output "container_registry_name" {
  value       = azurerm_container_registry.acrdesafiodevops1.name
  description = "Container Registry Name"
}

output "container_registry_login_server" {
  value       = azurerm_container_registry.acrdesafiodevops1.login_server
  description = "Container Registry Server to Login"
}

output "container_registry_admin_username" {
  value       = azurerm_container_registry.acrdesafiodevops1.admin_username
  description = "Username for basic authentication to the ACR"
}

output "container_registry_admin_password" {
  value       = azurerm_container_registry.acrdesafiodevops1.admin_password
  description = "Password for basic authentication to the Container Registry"
  sensitive   = true
}

output "kube_config" {
  value       =  azurerm_kubernetes_cluster.cluster_DesafioDevOps.kube_config_raw
  description = "AKS configuration"
  sensitive   = false
}
