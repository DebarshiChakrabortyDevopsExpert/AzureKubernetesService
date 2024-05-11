data "azurerm_client_config" "current" {}

data "azurerm_subnet" "aks_subnet" {

    for_each = {
    for k,v in try(var.aks_clusters, {}) : k => v
    if try(v.default_node_pool.subnet_name, null) != null
  }
        
    name     = each.value.default_node_pool.subnet_name
    resource_group_name = each.value.default_node_pool.vnet_rg
    virtual_network_name = each.value.default_node_pool.vnet_name
}

 data "azurerm_subnet" "app_gw_subnet" {

    for_each = {
    for k,v in try(var.aks_clusters, {}) : k => v
    if try(v.ingress_application_gateway.ingress_subnet_name, null) != null
    }

  name                  = each.value.ingress_application_gateway.ingress_subnet_name
  resource_group_name   = each.value.ingress_application_gateway.ingress_vnet_rg
  virtual_network_name  = each.value.ingress_application_gateway.ingress_vnet_name

 }

data "azurerm_log_analytics_workspace" "la" {
  for_each = {
    for k,v in try(var.aks_clusters, {}) : k => v
    if try(v.oms_agent, null) != null
  }    
     name                     = each.value.oms_agent.log_analytics_workspace_name
     resource_group_name      = each.value.oms_agent.log_analytics_workspace_rg
}

data "azurerm_kubernetes_cluster" "aks_cluster" {

  for_each = {
    for k,v in try(var.user_nodepools, {}) : k => v
    if try(v.aks_cluster_name, null) != null
  }
  name                = each.value.aks_cluster_name
  resource_group_name = each.value.aks_cluster_rg

  depends_on = [
    azurerm_kubernetes_cluster.akscluster
  ]
 

}