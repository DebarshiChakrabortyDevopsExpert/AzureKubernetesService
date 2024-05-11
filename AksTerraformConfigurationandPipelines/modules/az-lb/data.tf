data "azurerm_network_interface" "lb" {
    for_each = try(var.nic_bap_association, {})
    name                = each.value.name
    resource_group_name = try(each.value.resource_group_name, var.load_balancer.resource_group_name)
}
