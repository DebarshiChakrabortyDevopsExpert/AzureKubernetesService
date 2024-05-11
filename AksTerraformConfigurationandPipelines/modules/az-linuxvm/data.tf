data "azurerm_subscription" "current" {}

data "azurerm_subnet" "lvm_subnet" {
    for_each = var.configs.networking_interfaces
    name     = each.value ["subnet_name"]
    resource_group_name = each.value["vnet_rg"]
    virtual_network_name = each.value["vnet_name"]
}

data "azurerm_storage_account" "stgacc" {
  for_each = {
    for k,v in try(var.configs.vm_configs, {}) : k => v
    if try(v.diagnostic_stg_acc_name, null) != null
  }
  name                = each.value ["diagnostic_stg_acc_name"]
  resource_group_name = each.value ["diagnostic_stg_acc_rg_name"]
}

data "azurerm_network_security_group" "nsg" {
    for_each = {
        for key, value in try(var.configs.networking_interfaces, {}) : key => value
        if try(value.network_security_group, null) != null
    }
    name                = each.value.network_security_group
    resource_group_name = each.value.nsg_rg
}

data "azurerm_key_vault" "kv" {
  for_each = {
      for k,v in try(var.configs.vm_configs, {}) : k => v
      if try(v.local_admin_key_vault_name, null) != null
  }
  name                = each.value ["local_admin_key_vault_name"]
  resource_group_name = each.value ["local_admin_key_vault_rg_name"]
}

data "azurerm_key_vault_secret" "adminpassword" {
  for_each = {
      for k,v in try(var.configs.vm_configs, {}) : k => v
      if try(v.adminpassword_secret_name, null) != null
  }
  name         = each.value ["adminpassword_secret_name"]
  key_vault_id = data.azurerm_key_vault.kv[each.key].id
}

data "azurerm_backup_policy_vm" "policy" {
  for_each = {
    for k,v in try(var.configs.vm_configs,{}) :k => v
    if try(v.vm_backup_policy_name, null) != null
  }
  name                = each.value ["vm_backup_policy_name"]
  recovery_vault_name = each.value ["vm_rsv_name"]
  resource_group_name = each.value ["vm_rsv_rg_name"]
}

data "azurerm_proximity_placement_group" "linuxvm" {
  for_each = {
      for k,v in try(var.configs.vm_configs,{}) : k => v
      if try(v.ppg_name, null) != null
  }
  name                = each.value ["ppg_name"]
  resource_group_name = each.value ["vm_ppg_rg_name"]
}

data "azurerm_availability_set" "linuxvm" {
  for_each = {
      for k,v in try(var.configs.vm_configs,{}) : k => v
      if try(v.avset_name, null) != null
  }
  name                = each.value ["avset_name"]
  resource_group_name = each.value ["vm_rg"]
}

data "azurerm_log_analytics_workspace" "laworkspace" {
    for_each  = {
        for key,value in try(var.configs.vm_configs, {}) : key => value
        if try(value.log_analytics_workspace_name, null) != null
    }
    name                = each.value.log_analytics_workspace_name
    resource_group_name = each.value.resource_group_name
}