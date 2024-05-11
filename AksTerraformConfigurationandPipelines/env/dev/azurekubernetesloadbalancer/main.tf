module "load_balancer" {
  source                            = "../../../modules/az-lb"
  for_each                          = var.load_balancer 
  load_balancer                     = try(each.value.load_balancer, {})
  backends                          = try(each.value.backends, {})
  probes                            = try(each.value.probes, {})
  lb_rules                          = try(each.value.lb_rules, {})
  outbound_rules                    = try(each.value.outbound_rules, {})
  nat_pools                         = try(each.value.nat_pools, {})
  nat_rules                         = try(each.value.nat_rules, {})
  nic_bap_association               = try(each.value.nic_bap_association, {})
}
