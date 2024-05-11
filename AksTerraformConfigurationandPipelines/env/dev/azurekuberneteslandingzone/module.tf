module "resource_group" {
    source       = "../../../modules/az-rg"
    resource_groups = try(var.resource_groups, {})
}

module "virtual_networks" {
  source           = "../../../modules/az-vnet"
  virtual_networks = try(var.virtual_networks, {})

  depends_on = [
    module.resource_group,
  ]
}

module "Subnets" {
  source  = "../../../modules/az-subnet"
  subnets = try(var.subnets, {})
  depends_on = [
    module.virtual_networks
  ]
}

module "keyvault" {
    source                   = "../../../modules/az-keyvault"
    for_each                 = var.keyvaults
    keyvaults                = try(each.value.keyvaults, {})
    keyvault_access_policies = try(each.value.keyvault_access_policies, {})
    key_vault_pvt_endpnt     = try(each.value.key_vault_pvt_endpnt, {})

    depends_on = [
        module.resource_group,
        module.Subnets,
    ]
}

module "storage_accounts" {
    source              = "../../../modules/az-stg"
    for_each            = var.storage_accounts
    storage_accounts    = try(each.value.storage_accounts, {})
    blob_containers     = try(each.value.blob_containers, {})
    storage_pvt_endpnt  = try(each.value.storage_pvt_endpnt, {})

    depends_on = [
        module.resource_group,
        module.Subnets,
    ]
}

module "log_analytics" {
  source                  = "../../../modules/az-la"
  log_analytics           = try(var.log_analytics, {})
  log_analytics_solutions = try(var.log_analytics_solutions, {})

  depends_on = [
    module.resource_group
  ]
}

module "routetable" {
  source       = "../../../modules/az-rt"
  route_tables = try(var.route_tables, {})
  routes       = try(var.routes, {})
  rt_subnet    = try(var.rt_subnet, {})

  depends_on = [
    module.resource_group,
    module.Subnets
  ]
}

module "dnszone" {
  source      = "../../../modules/az-pdns"
  private_dns = try(var.private_dns, {})
  vnet_links  = try(var.vnet_links, {})
  depends_on = [
    module.resource_group,
    module.Subnets,
  ]
}

module "managedidentity" {
    source       = "../../../modules/az-managedid"
    managed_ids = try(var.managed_ids, {})

     depends_on = [
        module.resource_group,
    ]
}

module "role_assignments" {
    source       = "../../../modules/az-roleassignments"
    role_assignments = try(var.role_assignments, {})

    depends_on = [
        module.managedidentity,
        module.dnszone,
        module.resource_group,
    ]
}
