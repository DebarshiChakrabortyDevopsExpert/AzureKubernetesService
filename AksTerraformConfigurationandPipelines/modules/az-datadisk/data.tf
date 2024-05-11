data "azurerm_virtual_machine" "azurevm" {

    for_each = var.data_disks
    name     = each.value ["vm_to_attach"]
    resource_group_name =   each.value ["vm_rg"]
}