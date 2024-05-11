data "azurerm_subnet" "az_subnet" {
    for_each                            = var.rt_subnet
    name                               = each.value["rt_sub_name"]
    virtual_network_name               = each.value["rt_vnet_name"]
    resource_group_name                = each.value["sub_rg_name"]
}


data "azurerm_route_table" "rt_association" {
    for_each             = var.rt_subnet 
    name                = each.value["rt_name"]
    resource_group_name = each.value["rt_rg_name"]

    depends_on = [
        azurerm_route_table.route_table
    ]
}

#=========Firewall data=============

data "azurerm_firewall" "rt_firewall" {
  
   for_each = {
        for key, value in try(var.routes, {}) : key => value
        if try(value.firewall_name, null) != null
    }
  name                = each.value.firewall_name
  resource_group_name = each.value.fw_rg_name
 

 }
