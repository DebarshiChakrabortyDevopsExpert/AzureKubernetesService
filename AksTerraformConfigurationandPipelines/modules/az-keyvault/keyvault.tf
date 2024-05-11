resource "azurerm_key_vault" "keyvault" {

    name                            = var.keyvaults.name
    location                        = var.keyvaults.location
    resource_group_name             = var.keyvaults.resource_group_name
    tenant_id                       = data.azurerm_client_config.current.tenant_id
    sku_name                        = try(var.keyvaults.sku_name, "standard")
    tags                            = try(var.keyvaults.tags, null)
    public_network_access_enabled   = try(var.keyvaults.public_network_access_enabled, true)
    enabled_for_deployment          = try(var.keyvaults.enabled_for_deployment, false)
    enabled_for_disk_encryption     = try(var.keyvaults.enabled_for_disk_encryption, false)
    enabled_for_template_deployment = try(var.keyvaults.enabled_for_template_deployment, false)
    purge_protection_enabled        = try(var.keyvaults.purge_protection_enabled, false)
    soft_delete_retention_days      = try(var.keyvaults.soft_delete_retention_days, 7)
    enable_rbac_authorization       = try(var.keyvaults.enable_rbac_authorization, false)

    dynamic "network_acls" {
    for_each = try(var.keyvaults.network_acls, null) != null ? [var.keyvaults.network_acls] : []

    content {
        bypass                      = try(network_acls.value.bypass, "None")
        default_action              = try(network_acls.value.default_action, "Allow")
        ip_rules                    = try(network_acls.value.ip_rules, [])
        virtual_network_subnet_ids = flatten([for ids, value in try(network_acls.value.subnet_ids, {}) : "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${value.vnet_rg_name}/providers/Microsoft.Network/virtualNetworks/${value.vnet_name}/subnets/${value.subnet_name}"])
        }
    }

    dynamic "contact" {
    for_each = try(var.keyvaults.contact, null) != null ? [var.keyvaults.contact] : []

    content {
        email = contact.value.email
        name  = try(contact.value.name, null)
        phone = try(contact.value.phone, null)
        }
    }

    lifecycle {
    ignore_changes = [
            resource_group_name, location
        ]
    }
}  