param location string
//param subnetAddressSpace string
param adminUserName string
@secure()
param adminpassword string
param vmName array
param nicName array
param tags object = {
  environment: 'bicep'
  Owner: 'Ankita'
}

var vnetConfig = [
  {
    name: 'vnet01'
    addressPrefix: '10.0.0.0/16'
  }
  {
    name: 'vnet02'
    addressPrefix: '10.1.0.0/16'
  }
]
var subConfig = [
  {
    name: 'sub01'
    addressPrefix: '10.0.0.0/24'
  }
  {
    name: 'sub02'
    addressPrefix: '10.1.0.0/24'
  }
]
var nsgname = 'nsg01'
var windowsImagePublisher = 'MicrosoftWindowsServer'
var windowsImageOffer = 'WindowsServer'
var windowsImageSku = '2019-Datacenter'
//var vmName = 'computeVm'
var vmSize = 'Standard_DS1_v2'
//var nicName = 'compute-nic'
//var publicIpName = 'PbIP'
//var publicIPAllocationMethod = 'Dynamic'
//var publicIpSku = 'basic'
var createOption = 'FromImage'
var storageAccountType = 'StandardSSD_LRS'

@description('creation of network securuty group')
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgname
  location: location
  tags: tags

}

@description('creation of vnet')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = [for (config, i) in vnetConfig: {
  name: config.name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        config.addressPrefix
      ]
    }
  }
}]

@description('creation of subnet')
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = [for (config, i) in subConfig: {
  name: config.name
  parent: virtualNetwork[i]
  properties: {
    addressPrefix: config.addressPrefix
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }

  }
}]

/*@description('resources for public ip')
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod

  }
}*/

@description('resources for nic')
resource networkInterfaces 'Microsoft.Network/networkInterfaces@2023-02-01' = [for (nicName, i) in nicName: {
  name: nicName.name
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          /*publicIPAddress: {
            id: publicIp.id
          }*/
          subnet: {
            id: subnet[i].id

          }
        }
      }
    ]
  }
}]

@description('resources for vm')
resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = [for (vmName, i) in vmName: {
  name: vmName.name
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName.name
      adminUsername: adminUserName
      adminPassword: adminpassword
    }
    storageProfile: {
      imageReference: {
        publisher: windowsImagePublisher
        offer: windowsImageOffer
        sku: windowsImageSku
        version: 'latest'
      }
      osDisk: {
        createOption: createOption
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces[i].id
        }
      ]
    }
  }
}]
