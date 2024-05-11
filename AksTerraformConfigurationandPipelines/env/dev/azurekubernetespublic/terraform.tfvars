managed_ids = {

  managed_id1 = {
    managedid_name            = "mgaksiddvdeveus2003"
    resource_group_name       = "rg-aks-dev-eus2-001"
    location                  = "eastus2"
  }

  managed_id2 = {
    managedid_name            = "mgagtpliddvdeveus2003"
    resource_group_name       = "rg-aks-dev-eus2-001"
    location                  = "eastus2"
  }
}

# AKS CLUSTER

#=================
aks_clusters = {
    aks_cluster1 = { 
           aks_cluster_name = "aks-dv-dev-eus-202"
           aks_location = "EastUS2"

          # Azure requires that a new, non-existent Resource Group is used, as otherwise the provisioning of the Kubernetes Service will fail.

           aks_rg_name = "rg-aks-dev-eus2-001"

          # Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free
          
           aks_sku_tier               = "Standard"
           workload_identity_enabled  = true
           oidc_issuer_enabled        = true

           # Mention the ACR which needs to connected to the AKS Cluster
           acr_rg_name  = "rg-aks-dev-eus2-001"
           acr_name     = "acrdvdeveus201"

          ################################## System Node Pool  ##############################
             default_node_pool = {

                 name = "sysnodepool"
                 vm_size = "Standard_D4s_V3"
                 availability_zones = [1,2]
                 enable_auto_scaling = "true"
                 orchestrator_version = "1.25.6"
                 only_critical_addons_enabled = false
                 max_node_count = "3"
                 min_node_count = "1"
                 node_count     = "2"
                 node_pool_type = "VirtualMachineScaleSets"
                 enable_host_encryption = "false"
                 enable_node_public_ip = "false"
                 fips_enabled = "false"
                 # for default node pool, the max pod count should be larger than 30.
                 max_pods = 50

                 subnet_name    = "snet-rdl-nprd-db-eus2-001"
                 vnet_rg        = "rg-rdl-network-nprd-eus2"
                 vnet_name      = "vnet-rdl-nprd-eus2-001"
                                          
              }

             # Node Resource Group name must be in lowercase
               node_resource_group = "rg-aksnode-dev-eus2-002"
             
             # DNS Prefix
               aks_dns_prefix = "aksdvdeveus202"

          ############################ Identity  #############################

            identity = {
             type         = "UserAssigned"
             identity_ids = ["/subscriptions/xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx/resourceGroups/rg-aks-dev-eus2-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mgaksiddvdeveus2003"]

             }

             private_cluster_enabled    = false
             automatic_channel_upgrade  = "stable"
             kubernetes_version         = "1.25.6"
             local_account_disabled     = "true"

      
         ################################# Azure AD and RBAC ################################################

            azure_active_directory_role_based_access_control = {
                  managed                 = "true"
                  tenant_id               = "xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx"
                  azure_rbac_enabled      = "true"
                  admin_group_object_ids  = ["xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx"]               
            }

        ############################### network_profile  ##################################################   

            network_profile = {
                    network_plugin            = "azure"                    
                    network_mode              = "transparent"
                    network_policy            = "calico"
                    outbound_type             = "loadBalancer"
                    load_balancer_sku         = "standard"
                    outbound_ports_allocated  = 0
                    idle_timeout_in_minutes   = 50
                    managed_outbound_ip_count = 2
            }

        
        ########################## Maintenance Window ##################################################
            maintenance_window = {

              allowed =  {
                day = "Sunday"
                hourSlots = [1,2,3]
              }

              not_allowed = {      
                start= "2023-12-20T03:00:00Z"
                end = "2023-12-21T05:00:00Z"              
              }

            }


        ############################ Additional Configuration ###########################################
           
           kubelet_identity = {
            client_id                 = "xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx"
            object_id                 = "xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx"
            user_assigned_identity_id = "/subscriptions/xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx/resourceGroups/rg-aks-dev-eus2-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mgagtpliddvdeveus2003"
           }

            azure_policy_enabled = true

            oms_agent = {
                  log_analytics_workspace_name = "law-aks-dev-eus2-001"
                  log_analytics_workspace_rg = "rg-aks-dev-eus2-001"
        
            }

        ###################### Auto Scaler Profile #######################################################

         auto_scaler_profile = {  

           #  When you enable the cluster autoscaler, a default profile is used unless you specify different settings through below variables.

                 balance_similar_node_groups    = "false"
                 expander                       = "random"
                 max_graceful_termination_sec   = "600"
                 max_node_provisioning_time     = "15m"
                 max_unready_nodes              = "3"
                 max_unready_percentage         = "45"
                 new_pod_scale_up_delay         = "10s"
                 scale_down_delay_after_add     = "10m"
                 scale_down_delay_after_delete  = "10s"
                 scale_down_delay_after_failure = "3m"
                 scan_interval                  = "10s"
                 scale_down_unneeded            = "10m"
                 scale_down_unready             = "20m"
                 scale_down_utilization_threshold = "0.5"
                 empty_bulk_delete_max            = "10"
                 skip_nodes_with_local_storage    = "true"
                 skip_nodes_with_system_pods      = "true"

         }

        #  ingress_application_gateway = {           
        #    gateway_name         = "aksingress"        
        #    ingress_subnet_name  = "ingress"
        #    ingress_vnet_rg      = "aks-test"
        #    ingress_vnet_name    = "aks-test-vnet"         
          
        #   }
    }
}

user_nodepools = {
  user_nodepool1 = {
    nodepool_name          = "devstworker"
    aks_cluster_name       = "aks-dv-dev-eus-202"
    aks_cluster_rg         = "rg-aks-dev-eus2-001"
    vm_size                = "Standard_L32s_v3"
    mode                   = "User"
    max_node_count         = 5
    min_node_count         = 1
    node_count             = 1
    enable_auto_scaling    = true
    enable_node_public_ip  = false
    max_pods               = 15
    orchestrator_version   = "1.25.6"
    os_type                = "Linux"  
  }

    user_nodepool2 = {
    nodepool_name          = "devstcord"
    node_taints            = ["app=starburst-enterprise:NoSchedule","role=coordinator:NoSchedule",]
    aks_cluster_name       = "aks-dv-dev-eus-202"
    aks_cluster_rg         = "rg-aks-dev-eus2-001"
    vm_size                = "Standard_D4s_V3"
    mode                   = "User"
    node_count             = 1
    enable_auto_scaling    = false
    enable_node_public_ip  = false
    max_pods               = 15
    orchestrator_version   = "1.25.6"
    os_type                = "Linux"  
  }

    user_nodepool3 = {
    nodepool_name          = "devsthive"
    node_taints            = ["app=starburst-enterprise:NoSchedule","role=hive:NoSchedule",]
    aks_cluster_name       = "aks-dv-dev-eus-202"
    aks_cluster_rg         = "rg-aks-dev-eus2-001"
    vm_size                = "Standard_D4s_V3"
    mode                   = "User"
    node_count             = 1
    enable_auto_scaling    = false
    enable_node_public_ip  = false
    max_pods               = 15
    orchestrator_version   = "1.25.6"
    os_type                = "Linux"  
  }
}