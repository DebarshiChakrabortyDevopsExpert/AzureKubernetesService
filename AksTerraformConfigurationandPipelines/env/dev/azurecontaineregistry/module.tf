module "managedidentity" {
    source       = "../../../modules/az-managedid"
    managed_ids = try(var.managed_ids, {})
}

module "role_assignments" {
    source       = "../../../modules/az-roleassignments"
    role_assignments = try(var.role_assignments, {})
}


module "acr" {
    source                   = "../../../modules/az-acr"
    for_each                 = var.container_registries
    container_registry       = try(each.value.container_registry, {})
    acr_pvt_endpnt           = try(each.value.acr_pvt_endpnt, {})
}

