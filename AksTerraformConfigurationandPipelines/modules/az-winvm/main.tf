resource "azurerm_windows_virtual_machine" "windowsvm" {
  
  for_each            = try(var.configs.vm_configs, {})
  name                = each.value.vm_name
  location            = each.value.vm_location
  zone                = try(each.value.vm_avl_zone, null)
  resource_group_name = each.value.vm_rg
  size                = each.value.vm_size
  license_type        = each.value.vm_license_type
  admin_username      = each.value.admin_username
  admin_password      = try(data.azurerm_key_vault_secret.adminpassword[each.key].value, each.value.admin_password )
  network_interface_ids = flatten(
    [
      for nic_key,nic_data in var.configs.networking_interfaces : [
          azurerm_network_interface.nic[nic_key].id
        ]
    ]
  )
  provision_vm_agent    = true
  proximity_placement_group_id = try(data.azurerm_proximity_placement_group.windowsvm[each.key].id, null)
  availability_set_id          = try(data.azurerm_availability_set.windowsvm[each.key].id, null)
  tags                         = try(each.value.tags, null)

  os_disk {
    name                 = try(each.value.osdisk_name, "${each.value.vm_name}-OSDisk")
    disk_size_gb         = try(each.value.osdisk_size, null)
    caching              = try(each.value.osdisk_caching, "ReadWrite")
    storage_account_type = try(each.value.osdisk_storage_account_type, "Standard_LRS")
  }

  dynamic "boot_diagnostics" {
    for_each = lookup(each.value, "boot_diagnostics", null) != null ? [1] : []
    content {
      storage_account_uri = try(data.azurerm_storage_account.stgacc[each.key].primary_blob_endpoint, null)
    }
  }
  
  #Please use this for pulling image from shared image gallery (Either of soure_image_id or source_image_reference should be provided)
  source_image_id = try(each.value.custom_image_id, null)

  dynamic "source_image_reference" {
    for_each = lookup(each.value, "source_image_reference", null) != null ? [1] : []
    content {
      publisher = try(each.value.source_image_reference.publisher, null)
      offer     = try(each.value.source_image_reference.offer, null)
      sku       = try(each.value.source_image_reference.sku, null)
      version   = try(each.value.source_image_reference.version, null)
    }
  }

  dynamic "plan" {
    for_each = lookup(each.value, "plan", null) != null ? [1] : []
    content {
      name      = each.value.plan.name
      product   = each.value.plan.product
      publisher = each.value.plan.publisher
    }
  }

  dynamic "identity" {
        for_each = try(each.value.identity, false) == false ? [] : [1]
        content {
          type         = each.value.identity.type
          identity_ids = try(identity.value.managed_identities, null)
        }
  }

  lifecycle {
    ignore_changes = [
      admin_password,
      availability_set_id,
      proximity_placement_group_id
    ]
  }
  depends_on = [azurerm_network_interface.nic]
}

resource "azurerm_backup_protected_vm" "protected_vm" {
  for_each = {
    for k,v in try(var.configs.vm_configs,{}) : k => v
    if try(v.vm_backup_policy_name, null) != null
  }
  resource_group_name  = each.value.vm_rsv_rg_name
  recovery_vault_name  = each.value.vm_rsv_name
  source_vm_id         = azurerm_windows_virtual_machine.windowsvm[each.key].id
  backup_policy_id     = data.azurerm_backup_policy_vm.policy[each.key].id

  depends_on = [
    azurerm_windows_virtual_machine.windowsvm,
    data.azurerm_backup_policy_vm.policy
  ]
}