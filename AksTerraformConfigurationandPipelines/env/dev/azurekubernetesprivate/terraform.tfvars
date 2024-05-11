managed_ids = {

  managed_id1 = {
    managedid_name            = "mgaksiddvdeveus2001"
    resource_group_name       = "rg-aks-dev-eus2-001"
    location                  = "eastus2"
  }

  managed_id2 = {
    managedid_name            = "mgagtpliddvdeveus2001"
    resource_group_name       = "rg-aks-dev-eus2-001"
    location                  = "eastus2"
  }

}

private_dns = {
  st-pvtdns-zone1 = {
    name                = "privatelink.eastus2.azmk8s.io"
    resource_group_name = "rg-aks-dev-eus2-001"
    az_tags = {
       Environment     = "dev"
        }
    }
}

vnet_links = {
  dnszone1-vnethub-link1 = {
    name                  = "hub-sa-vnet-link-02"
    resource_group_name   = "rg-aks-dev-eus2-001"
    private_dns_zone_name = "privatelink.eastus2.azmk8s.io"
    vnet_name             = "vnet-rdl-nprd-eus2-001"
    vnet_rg               = "rg-rdl-network-nprd-eus2"
    registration_enabled  = false
    az_tags = {

         Environment = "AKS"
         }
   }
}

#Role Assigments
# ========================
role_assignments = {
  role_assignments1 = {
    name                    = "b24988ac-6180-42a0-ab88-20f7382dd24c"
    scope                   = "/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/rg-aks-dev-eus2-001/providers/Microsoft.Network/privateDnsZones/privatelink.eastus2.azmk8s.io"
    principle_id_name       = "mgaksiddvdeveus2001"
    principle_id_rg         = "rg-aks-dev-eus2-001"
    role_definition_name    = "Contributor"
  }

   role_assignments2 = {
    name                    = "f1a07417-d97a-45cb-824c-7a7467783830"
    scope                   = "/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourcegroups/rg-aks-dev-eus2-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mgagtpliddvdeveus2001"
    principle_id_name       = "mgaksiddvdeveus2001"
    principle_id_rg         = "rg-aks-dev-eus2-001"
    role_definition_name    = "Managed Identity Operator"
  }
}

# AKS CLUSTER
# TODO AKS values are still pending
#=================
aks_clusters = {
    aks_cluster1 = { 
           aks_cluster_name = "aksdvdeveus201"
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
                 only_critical_addons_enabled = true
                 max_node_count = "5"
                 min_node_count = "2"
                 default_node_count = "2"
                 node_pool_type = "VirtualMachineScaleSets"
                 enable_host_encryption = "false"
                 enable_node_public_ip = "false"
                 fips_enabled = "false"
                 # for default node pool, the max pod count should be larger than 30.
                 max_pods = 50

                 subnet_name = "snet-rdl-nprd-db-eus2-001"
                 vnet_rg = "rg-rdl-network-nprd-eus2"
                 vnet_name = "vnet-rdl-nprd-eus2-001"
                                          
              }

             # Node Resource Group name must be in lowercase
               node_resource_group = "rg-aksnode-dev-eus2-001"

             # DNS Prefix
             # One of dns_prefix or dns_prefix_private_cluster must be specified.

                #aks_dns_prefix = "aksdvdeveus201"
                dns_prefix_private_cluster = "aksdvdeveus201"
                
                dns_subscription_id = "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"
                dns_zone_name = "privatelink.eastus2.azmk8s.io"
                dns_resourcegroupname = "rg-aks-dev-eus2-001"

             ############################ Identity  #############################

            identity = {
             type = "UserAssigned"
             # If UserAssigned is set in identity_type, a user_assigned_identity_id must be set as well.
             identity_ids = ["/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/rg-aks-dev-eus2-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mgaksiddvdeveus2001"]

             }
           
             private_cluster_enabled = "true"

             # https:docs.microsoft.com/en-us/azure/aks/upgrade-cluster
             # Options are none,patch,stable,rapid,node-image

             automatic_channel_upgrade = "stable"

             # https:docs.microsoft.com/bs-cyrl-ba/azure/aks/api-server-authorized-ip-ranges

             # API server authorized IP address ranges are not supported for private clusters.

             #api_server_authorized_ip_ranges = ""

             kubernetes_version = "1.25.6"
             local_account_disabled = "true"

      
         ################################# Azure AD and RBAC ################################################

            azure_active_directory_role_based_access_control = {
      
                  managed = "true"
                  tenant_id = "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx"

                  azure_rbac_enabled = "true"
                
                # When managed is set to true the following properties can be specified:

                admin_group_object_ids = ["xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]               
                

                # When "azure_ad_managed" is set to false the following 3 properties can be specified:

                #client_app_id = ""
                #server_app_id = ""
                #server_app_secret = ""            

            }
   
            network_profile = {

                  ############################### network_profile  ##################################################

                    network_plugin = "azure"                    
                      # https:docs.microsoft.com/en-us/azure/aks/faq#what-is-azure-cni-transparent-mode-vs-bridge-mode
                    network_mode = "transparent"
                    #network_plugin_mode = "Overlay"
                    network_policy = "calico"
                    # IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)
                    #dns_service_ip = "10.0.4.10"
                    # IP address (in CIDR notation) used as the Docker bridge IP address on nodes
                    # docker_bridge_cidr = "172.17.0.1/16"
                    # The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet
                    #pod_cidrs = [""]
                    # The Network Range used by the Kubernetes service. Service address CIDR must be smaller than /12.
                    #service_cidr = "10.0.4.0/24"

                    # docker_bridge_cidr, dns_service_ip and service_cidr should all be empty or all should be set.


                    ################################### Egress ##################################################
                  
                      # The outbound (egress) routing method which should be used for this Kubernetes Cluster.
                    
                      outbound_type = "userDefinedRouting"
                      load_balancer_sku = "standard"

                      # Set Load Balancer Profile. This can only be specified when load_balancer_sku is set to Standard.

                      outbound_ports_allocated = 0
                      idle_timeout_in_minutes = 50
                      managed_outbound_ip_count = 2
                      #outbound_ip_prefix_ids =
                      #outbound_ip_address_ids =

                      # Set NAT Gateway Profile. 
                      # This can only be specified when load_balancer_sku is set to Standard and outbound_type is set to managedNATGateway or userAssignedNATGateway.

                      #idle_timeout_in_minutes_natgw = 4
                      #managed_outbound_ip_count_natgw = 1
            }

           ########################## Maintenance Window ##################################################

          # https:docs.microsoft.com/en-us/azure/aks/planned-maintenance

            maintenance_window = {

              allowed =  {

              # allowed
              day = "Sunday"
              hourSlots = [1,2,3]  # If you mention 1, that means the slot is from 1 AM to 2 AM. If you mention 1,2, that means slot is from 1 AM to 3 AM.

              }

              not_allowed = {      
                # not_allowed time window to perform any manitenance operation, even if it overlaps with a maintenance window.
                # Z stands for GMT Timezone.
              start= "2023-12-20T03:00:00Z"
              end = "2023-12-21T05:00:00Z"
              
                }

            }
           ############################ Additional Configuration ###########################################
           
           kubelet_identity = {
            client_id                 = "xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx"
            object_id                 = "xxxxx-xxxxxx-xxxxxx-xxxxxxxxx-xxxxxxxxxxxx"
            user_assigned_identity_id = "/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/rg-aks-dev-eus2-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mgagtpliddvdeveus2001"
           }

            azure_policy_enabled = true

            oms_agent = {
     
                  log_analytics_workspace_name = "law-aks-dev-eus2-001"

                  log_analytics_workspace_rg = "rg-aks-dev-eus2-001"
        
            }
           ###################### Auto Scaler Profile #######################################################

           # https:docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#using-the-autoscaler-profile

         auto_scaler_profile = {  

           #  When you enable the cluster autoscaler, a default profile is used unless you specify different settings through below variables.

                 balance_similar_node_groups = "false"
                 expander = "random"
                 max_graceful_termination_sec = "600"
                 max_node_provisioning_time = "15m"
                 max_unready_nodes = "3"
                 max_unready_percentage = "45"
                 new_pod_scale_up_delay = "10s"
                 scale_down_delay_after_add = "10m"
                 scale_down_delay_after_delete = "10s"
                 scale_down_delay_after_failure = "3m"
                 scan_interval = "10s"
                 scale_down_unneeded = "10m"
                 scale_down_unready = "20m"
                 scale_down_utilization_threshold = "0.5"
                 empty_bulk_delete_max = "10"
                 skip_nodes_with_local_storage = "true"
                 skip_nodes_with_system_pods = "true"

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
    aks_cluster_name       = "aksdvdeveus201"
    aks_cluster_rg         = "rg-aks-dev-eus2-001"
    vm_size                = "Standard_D2S_V3"
    mode                   = "User"
    max_node_count         = 6
    min_node_count         = 2
    node_count             = 2
    enable_auto_scaling    = true
    enable_node_public_ip  = false
    max_pods               = 15
    orchestrator_version   = "1.25.6"
    os_type                = "Linux"  
  }

    user_nodepool2 = {
    nodepool_name          = "devstcord"
    aks_cluster_name       = "aksdvdeveus201"
    aks_cluster_rg         = "rg-aks-dev-eus2-001"
    vm_size                = "Standard_DS2_v2"
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
    aks_cluster_name       = "aksdvdeveus201"
    aks_cluster_rg         = "rg-aks-dev-eus2-001"
    vm_size                = "Standard_DS2_v2"
    mode                   = "User"
    node_count             = 1
    enable_auto_scaling    = false
    enable_node_public_ip  = false
    max_pods               = 15
    orchestrator_version   = "1.25.6"
    os_type                = "Linux"  
  }
}