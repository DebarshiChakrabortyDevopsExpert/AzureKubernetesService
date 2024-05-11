resource "azurerm_key_vault_access_policy" "key_vault" {
    for_each = var.keyvault_access_policies

    key_vault_id            = azurerm_key_vault.keyvault.id
    tenant_id               = data.azurerm_client_config.current.tenant_id
    object_id               = each.value.object_id
    key_permissions         = try(each.value.key_permissions, null)
    secret_permissions      = try(each.value.secret_permissions, null)
    certificate_permissions = try(each.value.certificate_permissions, null)

    depends_on = [ 
        azurerm_key_vault.keyvault
    ]
}