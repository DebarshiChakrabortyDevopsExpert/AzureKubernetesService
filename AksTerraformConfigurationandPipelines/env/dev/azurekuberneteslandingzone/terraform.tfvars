# Resource Group ## Naming Done 
##=====================================================================
resource_groups = {
    resource_group1 = {
        resource_group_name = "rg-aks-dev-eus2-001"
        location            = "eastus2"
        az_tags = {
        Environment   = "Development"
        CostCenter    = "devcool"
        ResourceOwner = "devcool"
        Project       = "dev"
        Role          = "Resource Group"
        }
    }
    resource_group2 = {
        resource_group_name = "rg-data-dev-eus2-001"
        location            = "eastus2"
        az_tags = {
        Environment   = "Development"
        CostCenter    = "devcool"
        ResourceOwner = "devcool"
        Project       = "dev"
        Role          = "Resource Group"
        }
    }
}


## Create managed identity for AKS and AKS agentpool
managed_ids = {

  managed_id1 = {
    managedid_name            = "mgaksiddvdeveus2002"
    resource_group_name       = "rg-aks-dev-eus2-001"
    location                  = "eastus2"
  }

  managed_id2 = {
    managedid_name            = "mgagtpliddvdeveus2002"
    resource_group_name       = "rg-aks-dev-eus2-001"
    location                  = "eastus2"
  }

}

#Role Assigments
# ========================
role_assignments = {
   role_assignments1 = {
    name                    = "f1a07417-d97a-45cb-824c-7a7467783830"
    scope                   = "/subscriptions/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/resourceGroups/rg-aks-dev-eus2-001/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mgaksiddvdeveus2002"
    principle_id_name       = "mgaksiddvdeveus2002"
    principle_id_rg         = "rg-aks-dev-eus2-001"
    role_definition_name    = "Managed Identity Operator"
  }
}


# # Storage Accounts TODO (Dont have details for storage account)
# ##=====================================================================
storage_accounts = {

    storage_account1 = {

        storage_accounts = {
            name                        = "strgaksdeveus2001"
            resource_group_name         = "rg-aks-dev-eus2-001"
            location                    = "eastus2"
            account_tier                = "Standard"
            account_replication_type    = "GRS"
            
            network_rules = {
                default_action = "Allow"
            }
            
            blob_properties = {
                versioning_enabled      = false
                delete_retention_policy = {
                    days = 7
                }
                container_delete_retention_policy = {
                    days = 7
                }
            }
            
        }

        blob_containers = {
            blob_container1 = {
                container_name          = "container1"
                storage_account_name    = "strgaksdeveus2001"
                container_access_type   = "private"
            }
            blob_container2 = {
                container_name          = "container2"
                storage_account_name    = "strgaksdeveus2001"
                container_access_type   = "private"
            }  
        }

        storage_pvt_endpnt = {
            pvtendpoint1 = {
                name                    = "dev-devs-dev-pe-stg001"
                location                = "eastus2"
                resource_group_name     = "rg-aks-dev-eus2-001"
                subnet_name             = "snet-rdl-nprd-pe-eus2-001"
                vnet_name               = "vnet-rdl-nprd-eus2-001"
                vnet_rg_name            = "rg-rdl-network-nprd-eus2"
                private_connection_name = "dev-devs-dev-cn-stg001"
                subresource_names       = ["blob"]               
            }
            pvtendpoint2 = {
                name                    = "dev-devs-dev-pe-stg002"
                location                = "eastus2"
                resource_group_name     = "rg-aks-dev-eus2-001"
                subnet_name             = "snet-rdl-nprd-pe-eus2-001"
                vnet_name               = "vnet-rdl-nprd-eus2-001"
                vnet_rg_name            = "rg-rdl-network-nprd-eus2"
                private_connection_name = "dev-devs-dev-cn-stg002"
                subresource_names       = ["dfs"]
            }

        }
    }
}

# Azure Keyvault ## Naming Done 
##=====================================================================
keyvaults = {
    kv1 = {
        
        keyvaults = {
            name                = "kv-aks-dev-eus2-001"
            location            = "eastus2"
            resource_group_name = "rg-data-dev-eus2-001"
           
        }

        keyvault_access_policies = {
                policy1 = {
                    object_id               = "b0c15863-97d0-48a3-9d16-8b39313da0a5"
                    key_permissions         = ["Backup","Delete","Get","List","Purge","Recover","Restore","Create","Update"]
                    secret_permissions      = ["Backup","Delete","Get","List","Purge","Recover","Restore","Set"]
                    certificate_permissions = ["Backup","Delete","Get","List","Purge","Recover","Restore","Create","Update"]
                }              
                
        }

        key_vault_pvt_endpnt = {
            pvtendpoint1 = {
                name                    = "pe-kv-aks-dev-eus2-001"
                location                = "eastus2"
                resource_group_name     = "rg-data-dev-eus2-001"
                subnet_name             = "snet-rdl-nprd-pe-eus2-001"
                vnet_name               = "vnet-rdl-nprd-eus2-001"
                vnet_rg_name            = "rg-rdl-network-nprd-eus2"
                private_connection_name = "pecon-kv-aks-dev-eus2-001"
                
            }
        }
    }
}

# Azure Log Analytics Workspace ## Naming Done 
##=====================================================================
log_analytics = {
  testworkspace1 = {
    name                = "law-aks-dev-eus2-001"
    resource_group_name = "rg-aks-dev-eus2-001"
    location            = "eastus2"
  }
}