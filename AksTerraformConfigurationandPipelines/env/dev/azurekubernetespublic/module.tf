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
        module.dnszone
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

module "dnszone" {
  source                            = "../../../modules/az-pdns"
  private_dns                       = try(var.private_dns, {})
  vnet_links                        =  try(var.vnet_links, {})
   depends_on = [
        module.resource_group,
        module.virtual_networks,
    ]
}

module "aks" {
  source       = "../../../modules/az-aks"
  aks_clusters   = try(var.aks_clusters, {})
  user_nodepools = try(var.user_nodepools, {})

  depends_on = [
        module.managedidentity,
        module.dnszone,
        module.resource_group,
        module.virtual_networks,
        module.Subnets,
        module.role_assignments
    ]
}