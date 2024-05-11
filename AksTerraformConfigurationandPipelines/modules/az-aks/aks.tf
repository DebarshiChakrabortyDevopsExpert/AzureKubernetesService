
resource "azurerm_kubernetes_cluster" "akscluster" {

  for_each                    = var.aks_clusters
  name                        = each.value ["aks_cluster_name"]
  location                    = each.value ["aks_location"]
  enable_pod_security_policy  = try(each.value.enable_pod_security_policy, false)
  open_service_mesh_enabled   = try(each.value.open_service_mesh_enabled, false)
   # Azure requires that a new, non-existent Resource Group is used, otherwise the provisioning of the Kubernetes Service will fail.
  
  resource_group_name = each.value ["aks_rg_name"]

  sku_tier            = try(each.value.aks_sku_tier, "Free")

  workload_identity_enabled = try(each.value.workload_identity_enabled, false)
  oidc_issuer_enabled = try(each.value.oidc_issuer_enabled, false)

  key_vault_secrets_provider{
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  } 

  # AKS System Node Pool Configuration

  default_node_pool {
    
    name       = try(each.value.default_node_pool.name, "sysnodepool")
    vm_size    = try(each.value.default_node_pool.vm_size, "Standard_DS2_v2")
    zones      = try(each.value.default_node_pool.zones, null)
    enable_auto_scaling = try(each.value.default_node_pool.enable_auto_scaling, false)
    orchestrator_version = try(each.value.orchestrator_version, null)
    only_critical_addons_enabled = try(each.value.only_critical_addons_enabled, false)
    custom_ca_trust_enabled = try(each.value.custom_ca_trust_enabled, false)
    kubelet_disk_type       = try(each.value.kubelet_disk_type, "OS")
   # If enable_auto_scaling is set to true, then the following fields can also be configured :

    max_count = try(each.value.default_node_pool.max_node_count, null)
    min_count = try(each.value.default_node_pool.min_node_count, null)
    node_count = try(each.value.default_node_pool.node_count, null)  

   # If enable_auto_scaling = true then type = must be "VirtualMachineScaleSets"

    type = try(each.value.default_node_pool.node_pool_type, "VirtualMachineScaleSets")
    enable_host_encryption = try(each.value.default_node_pool.enable_host_encryption, false)
    enable_node_public_ip = try(each.value.default_node_pool.enable_node_public_ip, false)
    fips_enabled = try(each.value.default_node_pool.fips_enabled, false)
    max_pods   = try(each.value.default_node_pool.max_pods, 50)
    vnet_subnet_id = try(data.azurerm_subnet.aks_subnet[each.key].id, null)
   
  }

  # One of dns_prefix or dns_prefix_private_cluster must be specified.

  dns_prefix          = try(each.value ["aks_dns_prefix"], null)
  dns_prefix_private_cluster = try(each.value ["dns_prefix_private_cluster"], null)

  # If you are going to use an existing Private DNS Zone with AKS Cluster
  private_dns_zone_id = try("/subscriptions/${each.value.dns_subscription_id}/resourceGroups/${each.value.dns_resourcegroupname}/providers/Microsoft.Network/privateDnsZones/${each.value.dns_zone_name}",null)

  # one of either identity or service_principal blocks must be specified.

  identity {
    type = try(each.value.identity.type, "SystemAssigned")
    identity_ids = try(each.value.identity.identity_ids, [])
  }

  private_cluster_enabled = try(each.value ["private_cluster_enabled"], true)

 # https://docs.microsoft.com/en-us/azure/aks/upgrade-cluster#set-auto-upgrade-channel

   automatic_channel_upgrade = try(each.value ["automatic_channel_upgrade"], null)

 # https://docs.microsoft.com/bs-cyrl-ba/azure/aks/api-server-authorized-ip-ranges

 # API server authorized IP address ranges are not supported for private clusters.
  
  api_server_authorized_ip_ranges = try(each.value ["api_server_authorized_ip_ranges"], null)
  kubernetes_version = try(each.value ["kubernetes_version"], null)
  local_account_disabled = try(each.value ["local_account_disabled"], false)
  node_resource_group = try(each.value ["node_resource_group"], null)

 # AKS RBAC and Azure AD Integration

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = lookup(each.value,"azure_active_directory_role_based_access_control", null) == null ? [] : [1] 
      content {          
        managed = try(each.value.azure_active_directory_role_based_access_control.managed, null)
        tenant_id = try(each.value.azure_active_directory_role_based_access_control.tenant_id, null)
        # When managed is set to true the following properties can be specified:
        admin_group_object_ids = try(each.value.azure_active_directory_role_based_access_control.admin_group_object_ids, null)
        azure_rbac_enabled = try(each.value.azure_active_directory_role_based_access_control.azure_rbac_enabled, true)       
        # When managed is set to false the following properties can be specified:
        client_app_id = try(each.value.azure_active_directory_role_based_access_control.client_app_id, null)
        server_app_id = try(each.value.azure_active_directory_role_based_access_control.server_app_id, null)
        server_app_secret =  try(each.value.azure_active_directory_role_based_access_control.server_app_secret, null)            
      }
  }


 # AKS Network Profile

  dynamic "network_profile" {
    for_each = lookup(each.value,"network_profile", null) == null ? [] : [1] 
      content {
          network_plugin = try(each.value.network_profile.network_plugin, null)
          # https://docs.microsoft.com/en-us/azure/aks/faq#what-is-azure-cni-transparent-mode-vs-bridge-mode
          network_mode = try(each.value.network_profile.network_mode, null)
          network_plugin_mode = try(each.value.network_profile.network_plugin_mode, null)
          network_policy = try(each.value.network_profile.network_policy, null)
          # IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
          dns_service_ip = try(each.value.network_profile.dns_service_ip, null)
          # IP address (in CIDR notation) used as the Docker bridge IP address on nodes
          docker_bridge_cidr = try(each.value.network_profile.docker_bridge_cidr, null)
          # The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet
          pod_cidrs = try(each.value.network_profile.pod_cidrs, null)
          # The Network Range used by the Kubernetes service. Service address CIDR must be smaller than /12.
            service_cidr = try(each.value.network_profile.service_cidr, null)
          # docker_bridge_cidr, dns_service_ip and service_cidr should all be empty or all should be set.
          # The outbound (egress) routing method which should be used for this Kubernetes Cluster.
            outbound_type = try(each.value.network_profile.outbound_type, "loadBalancer")
            load_balancer_sku = try(each.value.network_profile.load_balancer_sku, "Standard")
        
          dynamic "load_balancer_profile" {
            for_each = lookup(each.value.network_profile,"load_balancer_profile", null) == null ? [] : [1] 
              content {       
                # This is a sub-block under Network Profile. This can only be specified when load_balancer_sku is set to Standard.
                  outbound_ports_allocated = try(each.value.network_profile.load_balancer_profile.outbound_ports_allocated, 0)
                  idle_timeout_in_minutes = try(each.value.network_profile.load_balancer_profile.idle_timeout_in_minutes, 30)
                  managed_outbound_ip_count = try(each.value.network_profile.load_balancer_profile.managed_outbound_ip_count, 1)
                  outbound_ip_prefix_ids = try(each.value.network_profile.load_balancer_profile.outbound_ip_prefix_ids, null)
                  outbound_ip_address_ids =  try(each.value.network_profile.load_balancer_profile.outbound_ip_address_ids, null)
                }
          }     
         
          dynamic "nat_gateway_profile" {
            for_each = lookup(each.value.network_profile,"nat_gateway_profile", null) == null ? [] : [1] 
            content {    
              # This is a sub-block under Network Profile.
              # This can only be specified when load_balancer_sku is set to Standard and outbound_type is set to managedNATGateway or userAssignedNATGateway.
              idle_timeout_in_minutes = try(each.value.network_profile.nat_gateway_profile.idle_timeout_in_minutes_natgw, 4)
              managed_outbound_ip_count = try(each.value.network_profile.nat_gateway_profile.managed_outbound_ip_count_natgw, 1)
            }
          }
        }
  }    
  

 # Below block defines maintenance window configuration for the AKS Cluster.
 # https://docs.microsoft.com/en-us/azure/aks/planned-maintenance

  maintenance_window {

      allowed {
          day = try(each.value.maintenance_window.allowed.day, null)
          hours = try(each.value.maintenance_window.allowed.hourSlots, null)
      }

      not_allowed {
          end = try(each.value.maintenance_window.not_allowed.end, null)
          start = try(each.value.maintenance_window.not_allowed.start, null)
      }
  }

  dynamic "kubelet_identity" {
    for_each = lookup(each.value,"kubelet_identity", null) == null ? [] : [1]
    content {
    client_id                 = try(each.value.kubelet_identity.client_id, null)
    object_id                 = try(each.value.kubelet_identity.object_id, null)
    user_assigned_identity_id = try(each.value.kubelet_identity.user_assigned_identity_id, null)
    }        
  }

 # Whether Azure Policy will be enbled for the AKS cluster

 azure_policy_enabled = try(each.value.azure_policy_enabled, true)  
 # OMS agent needs to be enabled for AKS Monitoring  

        dynamic "oms_agent" {
          for_each = lookup(each.value,"oms_agent", null) == null ? [] : [1] 
          content {    
          log_analytics_workspace_id = data.azurerm_log_analytics_workspace.la[each.key].id
          } 
        }
 # https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#using-the-autoscaler-profile
 # When you enable the cluster autoscaler, a default profile is used unless you specify different settings through below variables.

        dynamic "auto_scaler_profile" {
          for_each = lookup(each.value,"auto_scaler_profile", null) == null ? [] : [1] 
            content {
              balance_similar_node_groups = try(each.value.auto_scaler_profile.balance_similar_node_groups, null)
              expander = try(each.value.auto_scaler_profile.expander, null)
              max_graceful_termination_sec = try(each.value.auto_scaler_profile.max_graceful_termination_sec, null)
              max_node_provisioning_time = try(each.value.auto_scaler_profile.max_node_provisioning_time, null)
              max_unready_nodes = try(each.value.auto_scaler_profile.max_unready_nodes, null)
              max_unready_percentage = try(each.value.auto_scaler_profile.max_unready_percentage, null)
              new_pod_scale_up_delay  = try(each.value.auto_scaler_profile.new_pod_scale_up_delay, null)
              scale_down_delay_after_add = try(each.value.auto_scaler_profile.scale_down_delay_after_add, null)
              scale_down_delay_after_delete  = try(each.value.auto_scaler_profile.scale_down_delay_after_delete, null)
              scale_down_delay_after_failure = try(each.value.auto_scaler_profile.scale_down_delay_after_failure, null)
              scan_interval = try(each.value.auto_scaler_profile.scan_interval, null)
              scale_down_unneeded = try(each.value.auto_scaler_profile.scale_down_unneeded, null)
              scale_down_unready  = try(each.value.auto_scaler_profile.scale_down_unready, null)
              scale_down_utilization_threshold  = try(each.value.auto_scaler_profile.scale_down_utilization_threshold, null)
              empty_bulk_delete_max = try(each.value.auto_scaler_profile.empty_bulk_delete_max, null)
              skip_nodes_with_local_storage  = try(each.value.auto_scaler_profile.skip_nodes_with_local_storage, null)
              skip_nodes_with_system_pods  = try(each.value.auto_scaler_profile.skip_nodes_with_system_pods, null)
            }     
        }  

        dynamic "ingress_application_gateway"  {
         for_each = lookup(each.value,"ingress_application_gateway", null) == null ? [] : [1] 
          content {
          gateway_name = try(each.value.ingress_application_gateway.gateway_name, null)
          subnet_cidr  = try(each.value.ingress_application_gateway.subnet_cidr, null)
          subnet_id    = try(data.azurerm_subnet.app_gw_subnet[each.key].id, null)
          }
        }

        timeouts {
          create = try(each.value.timeouts.create,null)
          update = try(each.value.timeouts.update,null)
          read   = try(each.value.timeouts.read,null)
          delete = try(each.value.timeouts.delete,null)  
        }

        lifecycle {
          ignore_changes = [
             kubelet_identity,
             identity,
             default_node_pool[0].only_critical_addons_enabled,
             #node_resource_group,
             network_profile[0].load_balancer_profile,
             timeouts,
          ]
        }       
  
}