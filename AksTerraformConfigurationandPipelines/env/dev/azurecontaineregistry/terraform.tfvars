# Managed Identity 
#=================
managed_ids = {
  managed_id1 = {
    managedid_name            = "mgiddvdeveus2001"
    resource_group_name       = "rg-aks-dev-eus2-001"
    location                  = "eastus2"
  }
}

container_registries = {

    registry1 = {
        container_registry = {
            name                          = "acrdvdeveus201"
            resource_group_name           = "rg-aks-dev-eus2-001"
            location                      = "eastus2"
            sku                           = "Premium"
            admin_enabled                 = false
            public_network_access_enabled = true
            quarantine_policy_enabled     = false
            regional_endpoint_enabled     = false
            zone_redundancy_enabled       = false
            anonymous_pull_enabled        = false
            data_endpoint_enabled         = false
            network_rule_bypass_option    = "None"

                georeplications =  {
                    location                = "eastus"
                    zone_redundancy_enabled = false
                }

                identity = {
                    type                = "UserAssigned"
                    identity_ids = {
                      id1 = {
                        identity_rg_name = "rg-aks-dev-eus2-001"
                        identity_name    = "mgiddvdeveus2001"
                      }
                    }
                }        
        }
        
        acr_pvt_endpnt = {
            pvtendpoint1 = {
                name                    = "pe-acr-dv-dev-eus2-001"
                location                = "eastus2"
                resource_group_name     = "rg-data-dev-eus2-001"
                subnet_name             = "snet-rdl-nprd-pe-eus2-001"
                vnet_name               = "vnet-rdl-nprd-eus2-001"
                vnet_rg_name            = "rg-rdl-network-nprd-eus2"
                private_connection_name = "pecon-acr-dv-dev-eus2-001"

                private_dns_zone_group = {
                name = "acrgroup"
                dnszones = {
                    zone1 = {
                      dns_zone_name    = "privatelink.azurecr.io"
                      dns_zone_rg_name = "dev-rg-001"
                      subscription_id  = "xxxxxxx-xxxxxxx-xxx-xxx-xxxxxxxx"
                    }
                  }
                }
            }

        }
     
    }
}
