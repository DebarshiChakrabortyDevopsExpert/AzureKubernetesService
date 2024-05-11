## Windows VM's Jumpbox to Access Private AKS Cluster
##=====================================================================
windows_vms = {

## Windows Jumpbox
## Utility: Helm, kubectl, AZ CLI, VS Code, Terraform
    WinVM1 = {
          networking_interfaces = {
              nicwinvm1 = {
                  vm_location             = "eastus2"
                  vm_rg                   = "rg-aks-dev-eus2-001"              
                  subnet_name             = "snet-rdl-nprd-tools-eus2-001"
                  vnet_name               = "vnet-rdl-nprd-eus2-001"
                  vnet_rg                 = "rg-rdl-network-nprd-eus2"
                  enable_ip_forwarding    = false
                  ip_configurations = {
                  config1 ={
                      name = "primarywin01"
                      private_ip_address = "10.17.18.10"
                      primary = true
                  }
                  }   
              }
          }
          
          vm_configs = {
           config = {
              vm_name                       = "wvmaksdveus201"
              vm_location                   = "eastus2"
              vm_rg                         = "rg-aks-dev-eus2-001"
              vm_size                       = "Standard_D4s_v3"
              vm_license_type               = "Windows_Server"  
              local_admin_key_vault_name    = "kv-aks-dev-eus2-001"
              local_admin_key_vault_rg_name = "rg-data-dev-eus2-001"
              admin_username                = "localadmin"
              adminpassword_secret_name     = "vmpassword"

              source_image_reference = {
                  publisher = "MicrosoftWindowsServer"
                  offer     = "WindowsServer"
                  sku       = "2022-Datacenter"
                  version   = "latest"
              }

              log_analytics_workspace_name  = "law-aks-dev-eus2-001"
              resource_group_name           = "rg-aks-dev-eus2-001"
              diagnostic_stg_acc_name       = "vuldevnesa798"
              diagnostic_stg_acc_rg_name    = "test-rg-lbvm"
              vm_backup_policy_name         = "CustomBackupPolicy1"
              vm_rsv_name                   = "Module1RSV"
              vm_rsv_rg_name                = "test-rg-lbvm"
              virtual_machine_extensions = {
                  MicrosoftMonitoringAgent = {}
              }
            }
        }
    }

}

##Linux VM Jumpbox
##====================================================================

linux_vms = {


    linux_vm1 = {
        
        networking_interfaces = {
            niclinxvm1 = {
                vm_location                 = "eastus2"
                vm_rg                       = "rg-aks-dev-eus2-001"
                subnet_name                 = "snet-rdl-nprd-tools-eus2-001"
                vnet_name                   = "vnet-rdl-nprd-eus2-001"
                vnet_rg                     = "rg-rdl-network-nprd-eus2"
                enable_ip_forwarding        = false
                ip_configurations = {
                config1 ={
                    name = "primarylin01"
                    private_ip_address = "10.17.18.12"
                    primary = true
                }  
              }
          }
        }
        
        vm_configs = {
           config = {
                vm_name                       = "lvmstrdveus201"
                vm_location                   = "eastus2"
                vm_rg                         = "rg-aks-dev-eus2-001"
                vm_size                       = "Standard_D4s_v3"
                vm_license_type               = "SLES_BYOS"
                local_admin_key_vault_name    = "kv-aks-dev-eus2-001"
                local_admin_key_vault_rg_name = "rg-data-dev-eus2-001"
                admin_username                = "localadmin"
                adminpassword_secret_name     = "vmpassword"
                log_analytics_workspace_name  = "law-aks-dev-eus2-001"
                resource_group_name           = "rg-aks-dev-eus2-001"
                virtual_machine_extensions = {
                    OmsAgentForLinux = {}
                }
                source_image_reference = {
                    publisher = "RedHat"
                    offer     = "RHEL"
                    sku       = "82gen2"
                    version   = "latest"
                }
                identity = {
                    type = "SystemAssigned"
                }
                diagnostic_stg_acc_name         = "vuldevnesa798"
                diagnostic_stg_acc_rg_name      = "test-rg-lbvm"
                vm_backup_policy_name           = "CustomBackupPolicy1"
                vm_rsv_name                     = "Module1RSV"
                vm_rsv_rg_name                  = "test-rg-lbvm"
            }
        }
  }

}

## Data Disks
##=====================================================================
data_disks = {
  
  disk1 = {
    data_disk_name        = "datatdisk-aks-dve-eus2-001"
    vm_to_attach          = "wvmaksdveus201"
    vm_rg                 = "rg-aks-dev-eus2-001"
    data_disk_location    = "eastus2"
    data_disk_rg          = "rg-aks-dev-eus2-001"
    data_disk_size_gb     = "100"
    data_disk_lun         = "1"
    data_disk_caching     = "ReadWrite"   
    data_disk_type        = "Standard_LRS"
  }

  disk2 = {
    data_disk_name        = "datatdisk-aks-dve-eus2-002"
    vm_to_attach          = "lvmstrdveus201"
    vm_rg                 = "rg-aks-dev-eus2-001"
    data_disk_location    = "eastus2"
    data_disk_rg          = "rg-aks-dev-eus2-001"
    data_disk_size_gb     = "100"
    data_disk_lun         = "1"
    data_disk_caching     = "ReadWrite"   
    data_disk_type        = "Standard_LRS"
  }  

  disk3 = {
    data_disk_name        = "datatdisk-aks-dve-eus2-003"
    vm_to_attach          = "wvmpbidveus201"
    vm_rg                 = "rg-aks-dev-eus2-001"
    data_disk_location    = "eastus2"
    data_disk_rg          = "rg-aks-dev-eus2-001"
    data_disk_size_gb     = "100"
    data_disk_lun         = "1"
    data_disk_caching     = "ReadWrite"   
    data_disk_type        = "Standard_LRS"
  }
  
} 