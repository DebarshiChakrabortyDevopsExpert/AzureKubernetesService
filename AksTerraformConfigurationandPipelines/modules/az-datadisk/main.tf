resource "azurerm_managed_disk" "datadisk_create" {
  for_each                      = var.data_disks
  name                          = each.value["data_disk_name"]
  location                      = each.value["data_disk_location"]
  resource_group_name           = each.value["data_disk_rg"]
  storage_account_type          = each.value["data_disk_type"]
  create_option                 = "Empty"
  disk_size_gb                  = each.value["data_disk_size_gb"]
  zone                          = try(each.value ["data_disk_zone"], null)
  tags                          = try(each.value.tags, null)
  logical_sector_size           = try(each.value.logical_sector_size, null)
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
  on_demand_bursting_enabled    = try(each.value.on_demand_bursting_enabled, false)
  trusted_launch_enabled        = try(each.value.trusted_launch_enabled, false)
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk_attach" {
  for_each           = var.data_disks
  managed_disk_id    = azurerm_managed_disk.datadisk_create[each.key].id
  virtual_machine_id = data.azurerm_virtual_machine.azurevm[each.key].id
  lun                = each.value["data_disk_lun"]
  caching            = each.value["data_disk_caching"]
}