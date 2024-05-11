resource "azurerm_route_table" "route_table" {
    for_each                      =  var.route_tables
    name                          = each.value["rt_name"]
    location                      = each.value["location"]
    resource_group_name           = each.value["resource_group_name"]
    disable_bgp_route_propagation = each.value["disable_bgp_route_propagation"]
    tags                          = each.value["az_tags"]
}

resource "azurerm_route" "route" {
    for_each            = var.routes
    name                = each.value["route_name"]
    resource_group_name = each.value["route_rg"]
    route_table_name    = each.value["rt_name"]
    address_prefix      = each.value["address_prefix"]
    next_hop_type       = each.value["next_hop_type"]
   # next_hop_in_ip_address= each.value["next_hop_in_ip_address"]
    next_hop_in_ip_address= try(data.azurerm_firewall.rt_firewall[each.key].ip_configuration[0].private_ip_address, each.value.next_hop_in_ip_address, null)
    depends_on = [
        azurerm_route_table.route_table
    ]
}

resource "azurerm_subnet_route_table_association" "rt_sub_association" {
    for_each               = var.rt_subnet
    subnet_id             = data.azurerm_subnet.az_subnet[each.key].id
    route_table_id        = data.azurerm_route_table.rt_association[each.key].id
}