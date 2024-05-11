resource "azurerm_virtual_machine_extension" "extensions_MicrosoftMonitoringAgent" {
    for_each = {
        for key, value in try(var.configs.vm_configs, {}) : key => value
        if try(value.virtual_machine_extensions.MicrosoftMonitoringAgent, null) != null
    }    
    name                       = try(each.value.virtual_machine_extensions.MicrosoftMonitoringAgent.name, "MicrosoftMonitoringAgent")
    virtual_machine_id         = azurerm_windows_virtual_machine.windowsvm[each.key].id
    publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
    type                       = "MicrosoftMonitoringAgent"
    type_handler_version       = "1.0"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
    {
        "workspaceId" : "${data.azurerm_log_analytics_workspace.laworkspace[each.key].workspace_id}"
    }
    SETTINGS

    protected_settings = <<PROTECTED_SETTINGS
    {
        "workspaceKey" : "${data.azurerm_log_analytics_workspace.laworkspace[each.key].primary_shared_key}"
    }
    PROTECTED_SETTINGS
}
