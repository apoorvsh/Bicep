@description('Tags for the resources')
param resourceTags object
@description('Resource Location')
param location string
@description('Create Windows or Linux Virtual Machine as per the user choice')
@allowed([
  'windows'
  'linux'
])
param virtualMachineType string
@description('User Name for login into VM')
@secure()
param vmUserName string
@description('Password for login into VM')
@secure()
param vmPassword string
@description('Reference Public IP resource ID from another module')
param publicIPRef string
@description('Network Interface Name')
param nicName string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Compute Endpoint Subnet Name')
param computeSubnetName string
@description('Virtual Machine Name')
param vmName string
@description('Virtual Machine Os Disk Name')
param vmOsDiskName string
@description('Azure Virual should be part of Availability Zone or Availability set')
@allowed([
  'Availability_Zone'
  'Availability_Set'
  'null'
])
param availabilityOption string
@description('Reference Availability Set resourec ID form another module')
param availabilitySetRef string
@description('Resource Name of the storage account that will have the Azure Activity log sent to')
param storageAccountName string = ''
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool = false

// variables
@description('Private IP allocation method for NIC')
var privateIpAllocationMethod = 'Dynamic'
@description('Virtual Machine Size')
var vmSize = 'Standard_D2s_v3'
@description('Virtual Machine OS Disk type')
var storageAccountType = 'StandardSSD_LRS'
@description('Virtual Machine computer Name')
var computerName = virtualMachineType == 'windows' ? 'window-vm' : 'linux-vm'
@description('Virtual Machine OS disk Create Option')
var osDiskCreateOption = 'FromImage'
@description('Virtual Machine availabilty Zone')
var zones = [
  '1'
]
var imageReference = virtualMachineType == 'windows' ? windowImageReference : linuxImageReference
var linuxImageReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18_04-lts-gen2'
  version: 'latest'
}
/*@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])*/
var windowImageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-datacenter-gensecond'
  version: 'latest'
}

// creation of network interface card
resource networkInterface 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  tags: resourceTags
  properties: {
    ipConfigurations: [
      {
        name: 'ip-config'
        properties: {
          privateIPAllocationMethod: privateIpAllocationMethod
          publicIPAddress: !empty(publicIPRef) ? {
            id: publicIPRef
          } : null
          subnet: {
            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${computeSubnetName}'
          }
        }
      }
    ]
  }
}

// creation of virtual machine
resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    availabilitySet: !empty(availabilitySetRef) && contains(availabilityOption, 'Availability_Set') ? {
      id: availabilitySetRef
    } : null
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: vmUserName
      adminPassword: vmPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: vmOsDiskName
        createOption: osDiskCreateOption
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: !(empty(storageAccountName)) && enableDiagnosticSetting == true ? true : false
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
  zones: ((contains(availabilityOption, 'Availability_Zone')) ? zones : null)
}
