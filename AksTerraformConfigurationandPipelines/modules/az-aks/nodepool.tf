resource "azurerm_kubernetes_cluster_node_pool" "usernodepool" {
  for_each                = var.user_nodepools

  name                    = each.value.nodepool_name
  kubernetes_cluster_id   = data.azurerm_kubernetes_cluster.aks_cluster[each.key].id
  vm_size                 = each.value.vm_size  
  custom_ca_trust_enabled = try(each.value.custom_ca_trust_enabled, false)
  enable_host_encryption  = try(each.value.enable_host_encryption, false)
  fips_enabled            = try(each.value.fips_enabled, false)
  mode                  = try(each.value.mode, "User")
  enable_auto_scaling   = try(each.value.enable_auto_scaling, false)
  enable_node_public_ip = try(each.value.enable_node_public_ip, false)
  max_pods              = try(each.value.max_pods, null)
  orchestrator_version  = try(each.value.orchestrator_version, null)
  node_taints           = try(each.value.node_taints, null)
# If enable_auto_scaling is set to true, then the following fields can also be configured :

  max_count             = try(each.value.max_node_count, null)
  min_count             = try(each.value.min_node_count, null)

# Node count setting is required whether auto scaling is set to TRUE or FALSE.

  node_count            = try(each.value.node_count, null)
  os_type               = try(each.value.os_type, "Linux") 

   lifecycle {
          ignore_changes = [
             custom_ca_trust_enabled,
             enable_host_encryption,
             fips_enabled,
             vnet_subnet_id,
             kubernetes_cluster_id,
          ]
        } 
    
}