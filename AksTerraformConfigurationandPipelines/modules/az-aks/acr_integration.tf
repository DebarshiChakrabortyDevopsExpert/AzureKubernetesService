resource "azurerm_role_assignment" "aks_acrpull_roleassigment" {
  for_each                         = var.aks_clusters
  principal_id                     = azurerm_kubernetes_cluster.akscluster[each.key].kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${each.value.acr_rg_name}/providers/Microsoft.ContainerRegistry/registries/${each.value.acr_name}"
  skip_service_principal_aad_check = true

   lifecycle {
          ignore_changes = [
             principal_id,
          ]
        }       
  
}

