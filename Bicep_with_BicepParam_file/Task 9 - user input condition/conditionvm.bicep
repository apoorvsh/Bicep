param location string = 'Central India'
param nsgName string = 'nsg'

param publicIPAddressName string = 'pip'
param publicIPSKU string = 'Basic'
param publicIPAddressType string = 'Dynamic'
param networkInterfaceName string = 'nic'
@allowed([
  'Windows'
  'Linux'
])
param virtualMachineName string 
param vmSize string = 'Standard_D2s_v5'
param adminUsername string 
@secure()
param adminPassword string = 'Hemang@12345'
param securityType string = 'Standard'

var osdisktype = virtualMachineName == 'Windows' ? 'StandardSSD_LRS' : 'Standard_LRS'
var osVersion =  virtualMachineName == 'Windows'? '2022-datacenter-azure-edition' : '20_04-lts-gen2'
var destinationPortRange = virtualMachineName == 'Windows' ? '3389' : '22'
var securityRuleName = virtualMachineName == 'Windows' ? 'RDP' : 'SSH'
var publisher = virtualMachineName == 'Windows' ? 'MicrosoftWindowsServer' : 'canonical'
var offer = virtualMachineName == 'Windows' ? 'WindowsServer' : '0001-com-ubuntu-server-focal'
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
       {
        name: securityRuleName
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: destinationPortRange
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
       }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'VNET'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: 'subnet'
  parent: vnet

  
  
}



resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIPAddressName
  location: location
  sku: {
    name: publicIPSKU
  }
  properties: {
    publicIPAllocationMethod: publicIPAddressType
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
       {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: subnet.id
          }
        }
       }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {

      imageReference: {
        publisher: publisher
        offer: offer
        sku: osVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osdisktype
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
          id: nic.id
        }
      ]
    }
    
    securityProfile: ((securityType == 'Standard') ? securityProfileJson : null)
  }
}
