#Create Load Balancers
resource "azurerm_lb" "lb" {
    name                      = var.load_balancer.name
    resource_group_name       = var.load_balancer.resource_group_name
    location                  = var.load_balancer.location
    sku                       = var.load_balancer.sku
    sku_tier                  = var.load_balancer.sku_tier
    tags                      = try(var.load_balancer.tags, null)

    dynamic "frontend_ip_configuration" {
        for_each = try(var.load_balancer.frontend_ip_configuration, null) != null ? [var.load_balancer.frontend_ip_configuration] : []

        content {
        name                            = frontend_ip_configuration.value.name
        subnet_id                       = try("/subscriptions/${var.load_balancer.lb_vnet_subscription_id}/resourceGroups/${var.load_balancer.lb_vnet_rg}/providers/Microsoft.Network/virtualNetworks/${var.load_balancer.lb_vnet_name}/subnets/${var.load_balancer.lb_subnet_name}", null)
        private_ip_address              = try(frontend_ip_configuration.value.private_ip_address, null)
        private_ip_address_allocation   = try(frontend_ip_configuration.value.private_ip_address_allocation, "Static")
        }
    }
}

# Create Backend address pools
resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
    for_each        = try(var.backends, {})
    loadbalancer_id = azurerm_lb.lb.id
    name            = each.value.backend_name
    depends_on      = [azurerm_lb.lb]
}

# Create Load Balancer Probes
resource "azurerm_lb_probe" "lb_probe" {
    for_each = try(var.probes, {})
    loadbalancer_id     = azurerm_lb.lb.id
    name                = each.value.probe_name
    port                = each.value.port
    protocol            = try(each.value.protocol, null)            
    request_path        = try(each.value.request_path, null)        
    interval_in_seconds = try(each.value.interval_in_seconds, null) 
    number_of_probes    = try(each.value.number_of_probes, null)    

    depends_on = [
        azurerm_lb_backend_address_pool.backend_address_pool,
        azurerm_lb.lb
    ]
}

# Create Load Balancer Rules
resource "azurerm_lb_rule" "lb_rule" {
    for_each = try(var.lb_rules, {})

    loadbalancer_id                = azurerm_lb.lb.id
    name                           = each.value.lb_rule_name
    protocol                       = each.value.protocol
    frontend_port                  = each.value.frontend_port
    backend_port                   = each.value.backend_port
    frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
    backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_address_pool[each.value.backend_key].id]
    probe_id                       = try(azurerm_lb_probe.lb_probe[each.value.probe_id_key].id, null)
    enable_floating_ip             = try(each.value.enable_floating_ip, null)
    idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, null)
    load_distribution              = try(each.value.load_distribution, null)
    disable_outbound_snat          = try(each.value.disable_outbound_snat, true)
    enable_tcp_reset               = try(each.value.enable_tcp_reset, null)

    depends_on = [
        azurerm_lb_backend_address_pool.backend_address_pool,
        azurerm_lb_probe.lb_probe
    ]
}

resource "azurerm_lb_outbound_rule" "outbound_rule" {
    for_each = try(var.outbound_rules, {})

    loadbalancer_id          = azurerm_lb.lb.id
    name                     = each.value.name
    protocol                 = each.value.protocol
    backend_address_pool_id  = azurerm_lb_backend_address_pool.backend_address_pool[each.value.backend_key].id
    enable_tcp_reset         = try(each.value.enable_tcp_reset, null)
    allocated_outbound_ports = try(each.value.allocated_outbound_ports, null)
    idle_timeout_in_minutes  = try(each.value.idle_timeout_in_minutes, null)


    dynamic "frontend_ip_configuration" {
        for_each = try(each.value.frontend_ip_configuration, null) != null ? [each.value.frontend_ip_configuration] : []
        content {
        name = frontend_ip_configuration.value.name
        }
    }

    depends_on = [
        azurerm_lb_backend_address_pool.backend_address_pool,
        azurerm_lb_probe.lb_probe
    ]
}

resource "azurerm_lb_nat_pool" "nat_pool" {
    for_each = try(var.nat_pools, {})

    resource_group_name            = try(each.value.resource_group_name, var.load_balancer.resource_group_name)
    loadbalancer_id                = azurerm_lb.lb.id
    name                           = each.value.name
    protocol                       = each.value.protocol
    frontend_port_start            = each.value.frontend_port_end
    frontend_port_end              = each.value.frontend_port_end
    backend_port                   = each.value.backend_port
    frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
    idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, null)
    floating_ip_enabled            = try(each.value.floating_ip_enabled, null)
    tcp_reset_enabled              = try(each.value.tcp_reset_enabled, null)
}

resource "azurerm_lb_nat_rule" "nat_rule" {
    for_each = try(var.nat_rules, {})

    resource_group_name            = try(each.value.resource_group_name, var.load_balancer.resource_group_name)
    loadbalancer_id                = azurerm_lb.lb.id
    name                           = each.value.name
    protocol                       = each.value.protocol
    frontend_port                  = each.value.frontend_port
    backend_port                   = each.value.backend_port
    frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
    idle_timeout_in_minutes        = try(each.value.idle_timeout_in_minutes, null)
    enable_floating_ip             = try(each.value.enable_floating_ip, null)
    enable_tcp_reset               = try(each.value.enable_tcp_reset, null)
}

resource "azurerm_network_interface_backend_address_pool_association" "vm_nic_bap_association" {
    for_each = try(var.nic_bap_association, {})

    network_interface_id    = data.azurerm_network_interface.lb[each.key].id
    ip_configuration_name   = data.azurerm_network_interface.lb[each.key].ip_configuration[0].name
    backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool[each.value.backend_key].id
}