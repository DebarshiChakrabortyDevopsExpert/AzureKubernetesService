module "windows_vms" {
  source      = "../../../modules/az-winvm"
  for_each    = try(var.windows_vms, {})
  windows_vms = var.windows_vms
  configs     = each.value
}

module "linux_vms" {
  source    = "../../../modules/az-linuxvm"
  for_each  = try(var.linux_vms, {})
  linux_vms = var.linux_vms
  configs   = each.value
}

module "data_disks" {
  source     = "../../../modules/az-datadisk"
  data_disks = try(var.data_disks, {})

  depends_on = [
    module.linux_vms,
    module.windows_vms
  ]
}

