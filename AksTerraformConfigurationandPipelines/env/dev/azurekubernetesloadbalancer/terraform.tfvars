load_balancer = {
    
  lb1 = {
    load_balancer = {
        name                   = "ilb-pbi-dev-eus2-001"
        resource_group_name    = "rg-aks-dev-eus2-001"
        location               = "eastus2"
        sku                    = "Standard"
        sku_tier               = "Regional"
        lb_vnet_subscription_id= "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        lb_vnet_name           = "vnet-rdl-nprd-eus2-001"
        lb_vnet_rg             = "rg-rdl-network-nprd-eus2"
        lb_subnet_name         = "snet-rdl-nprd-appgw-eus2-001"
        tags                   = {
            env = "dev"
        }
        frontend_ip_configuration = {
            name                           = "lbinternal"
            private_ip_address             = "10.17.22.166"
            private_ip_address_allocation  = "Static"
        }
    }
 }

 ## AKS ILB
  lb2 = {
    load_balancer = {
        name                   = "ilb-aks-dev-eus2-001"
        resource_group_name    = "rg-aks-dev-eus2-001"
        location               = "eastus2"
        sku                    = "Standard"
        sku_tier               = "Regional"
        lb_vnet_subscription_id= "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        lb_vnet_name           = "vnet-rdl-nprd-eus2-001"
        lb_vnet_rg             = "rg-rdl-network-nprd-eus2"
        lb_subnet_name         = "snet-rdl-nprd-appgw-eus2-001"
        tags                   = {
            env = "dev"
        }
        frontend_ip_configuration = {
            name                           = "lbinternal"
            private_ip_address             = "10.17.22.167"
            private_ip_address_allocation  = "static"
        }
    }
 }

}