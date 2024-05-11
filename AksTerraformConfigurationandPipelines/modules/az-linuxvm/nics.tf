resource "azurerm_network_interface" "nic" {
    for_each = var.configs.networking_interfaces

    name                = each.key
    location            = each.value.vm_location
    resource_group_name = each.value.vm_rg

    dns_servers                   = lookup(each.value, "dns_servers", null)
    enable_ip_forwarding          = lookup(each.value, "enable_ip_forwarding", false)
    enable_accelerated_networking = lookup(each.value, "enable_accelerated_networking", false)
    internal_dns_name_label       = lookup(each.value, "internal_dns_name_label", null)
    tags                          = try(each.value.tags, null)

    dynamic "ip_configuration" {
        for_each = try(each.value.ip_configurations, {})

        content {
        name                          = ip_configuration.value.name
        subnet_id                     = data.azurerm_subnet.lvm_subnet[each.key].id
        private_ip_address_allocation = try(ip_configuration.value.private_ip_address, null) == null ? "Dynamic" : "Static"
        private_ip_address_version    = lookup(ip_configuration.value, "private_ip_address_version", null)
        private_ip_address            = try(ip_configuration.value.private_ip_address, null)
        public_ip_address_id          = try(ip_configuration.value.public_ip_name, null) != null ? "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${ip_configuration.value.public_ip_rg}/providers/Microsoft.Network/publicIPAddresses/${ip_configuration.value.public_ip_name}" : null
        primary                       = try(ip_configuration.value.primary, false)
        }
    }
}

resource "azurerm_network_interface_security_group_association" "nic" {
    for_each = {
        for key, value in try(var.configs.networking_interfaces, {}) : key => value
        if try(value.network_security_group, null) != null
    }

    network_interface_id      = azurerm_network_interface.nic[each.key].id
    network_security_group_id = data.azurerm_network_security_group.nsg[each.key].id
}