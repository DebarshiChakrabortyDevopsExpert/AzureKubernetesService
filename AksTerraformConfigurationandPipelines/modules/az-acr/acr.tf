resource "azurerm_container_registry" "acr" {

  name                            = var.container_registry.name
  resource_group_name             = var.container_registry.resource_group_name
  location                        = var.container_registry.location
  sku                             = try (var.container_registry.sku, null)
  admin_enabled                   = try (var.container_registry.admin_enabled, null)
  public_network_access_enabled   = try (var.container_registry.public_network_access_enabled, false)
  quarantine_policy_enabled       = try (var.container_registry.quarantine_policy_enabled, null)
  zone_redundancy_enabled         = try (var.container_registry.zone_redundancy_enabled, null)
  anonymous_pull_enabled          = try (var.container_registry.anonymous_pull_enabled, false)
  data_endpoint_enabled           = try (var.container_registry.data_endpoint_enabled, null)
  network_rule_bypass_option      = try (var.container_registry.network_rule_bypass_option, null)

    dynamic "georeplications" {
      for_each = try(var.container_registry.georeplications, null) != null ? [var.container_registry.georeplications] : []
      
      content {
      location                  = try(georeplications.value.location, false)
      zone_redundancy_enabled   = try(georeplications.value.zone_redundancy_enabled, true)
      }
    }

    dynamic "identity" {
      for_each = try(var.container_registry.identity, null) != null ? [var.container_registry.identity] : []
          
          content {
              type           = identity.value.type
              identity_ids = flatten([for ids, value in try(identity.value.identity_ids, {}) : "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${value.identity_rg_name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${value.identity_name}"])
          }
      }

    dynamic "network_rule_set" {
        for_each = try(var.container_registry.network_rule_set, null) != null ? [var.container_registry.network_rule_set] : []  
          
          content {
            default_action = try(network_rule_set.value.default_action,"Deny")
            
            dynamic "ip_rule" {
              for_each = try (container_registry.value.ip_rule, null) != null ? [container_registry.value.ip_rule] : []
                content {
                    action    = try(ip_rule.value.action,null)
                    ip_range  = try(ip_rule.value.ip_range,null)
                } 
            }

            dynamic "virtual_network" {
              for_each = try (container_registry.value.virtual_network, null) != null ? [container_registry.value.virtual_network] : []
                content {
                    action    = try(virtual_network.value.action,null)
                    subnet_id = try(virtual_network.value.subnet_id, null)
                } 
            }
          }
    }

}
  