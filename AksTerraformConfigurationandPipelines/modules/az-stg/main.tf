resource "azurerm_storage_account" "stgaccount" {
  name                     = var.storage_accounts.name
  resource_group_name      = var.storage_accounts.resource_group_name
  location                 = var.storage_accounts.location
  account_tier             = var.storage_accounts.account_tier
  account_replication_type = var.storage_accounts.account_replication_type

  account_kind             = try(var.storage_accounts.account_kind, "StorageV2")
  access_tier              = try(var.storage_accounts.access_tier, "Hot")
  nfsv3_enabled            = try(var.storage_accounts.nfsv3_enabled, false)
  public_network_access_enabled = try(var.storage_accounts.public_network_access_enabled, true)
  
  enable_https_traffic_only = try(var.storage_accounts.enable_https_traffic_only , true)
  min_tls_version           = try(var.storage_accounts.min_tls_version, "TLS1_2")
  allow_nested_items_to_be_public   = try(var.storage_accounts.allow_nested_items_to_be_public, false)
  ## Should be set to true to enable data lake storage
  is_hns_enabled            = try(var.storage_accounts.is_hns_enabled, true)
  shared_access_key_enabled = try(var.storage_accounts.shared_access_key_enabled, true)
  
  large_file_share_enabled  = try(var.storage_accounts.large_file_share_enabled, false)
  tags                      = try(var.storage_accounts.tags, null)

  dynamic "network_rules" {
    for_each = try(var.storage_accounts.network_rules, null) != null ? [var.storage_accounts.network_rules] : []

    content {
        bypass                      = try(network_rules.value.bypass, [])
        default_action              = try(network_rules.value.default_action, "Allow")
        ip_rules                    = try(network_rules.value.ip_rules, [])
        virtual_network_subnet_ids = flatten([for ids, value in try(network_rules.value.subnet_ids, {}) : "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${value.vnet_rg_name}/providers/Microsoft.Network/virtualNetworks/${value.vnet_name}/subnets/${value.subnet_name}"])
    }
  }

  dynamic "blob_properties" {
    for_each = try(var.storage_accounts.blob_properties, null) != null ? [var.storage_accounts.blob_properties] : []

    content {
        versioning_enabled        = try(blob_properties.value.versioning_enabled, false)
        last_access_time_enabled  = try(blob_properties.value.last_access_time_enabled, true)
        change_feed_enabled       = try(blob_properties.value.change_feed_enabled, null)
        default_service_version   = try(blob_properties.value.default_service_version, "2020-06-12")
        delete_retention_policy {
          days = try(blob_properties.value.delete_retention_policy.days, 7)
        }
        container_delete_retention_policy {
          days = try(blob_properties.value.container_delete_retention_policy.days, 7)
        }
    }
  }

  # dynamic "share_properties" {
  #   for_each = try(var.storage_accounts.share_properties, null) != null ? [var.storage_accounts.share_properties] : []

  #   content {
  #       retention_policy {
  #         days = try (share_properties.value.retention_policy.days, 7)
  #       }
  #       smb {
  #         versions = try (share_properties.value.smb.versions, ["SMB3.0"])
  #       }
  #   }
  # }

  # queue_encryption_key_type = try (var.storage_accounts.queue_encryption_key_type, "Service")
  # table_encryption_key_type = try (var.storage_accounts.table_encryption_key_type, "Service")

}