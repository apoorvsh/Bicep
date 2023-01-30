// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('User Name for login into Jump Server VM')
@secure()
param vmUserName string
@description('Password for login into Jump Server VM')
@secure()
param adminPassword string

// variables
var jumpServerVmNicName = toLower('nic${projectCode}${environment}1jumphost01')
var privateIpAllocationMethod = 'Dynamic'
var jumpServerVmName = toLower('vm${projectCode}${environment}1jumphost01')
var vmSize = 'Standard_D4s_v3'
var storageProfileSku = '2019-datacenter-gensecond'
var storageProfilePublisher = 'MicrosoftWindowsServer'
var storageProfileOffer = 'WindowsServer'
var storageProfileVersion = 'latest'
var jumpServerVmOsDiskName = toLower('osdisk-${projectCode}-${environment}-jumphost01')

var computerName = 'jump-vm'
var osDiskCreateOption = 'FromImage'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'apoorv-vnet'
  location: location
  tags: combineResourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'vnetsubnet'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'windpow'
  location: location
  properties: {
    securityRules: [
      {
        name: 'rdp'
        properties: {
          description: 'description'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'windpwpub'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// creation of network interface card
resource jumpSeverVmNetworkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: jumpServerVmNicName
  location: location
  tags: union({
      Name: jumpServerVmNicName
    }, combineResourceTags)
  properties: {
    ipConfigurations: [
      {
        name: 'jump-server-vm-ip-congig'
        properties: {
          privateIPAllocationMethod: privateIpAllocationMethod
          publicIPAddress: {
            id: publicip.id
          }
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

// creation of window virtual machine
resource jumpServerVm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: jumpServerVmName
  location: location
  tags: union({
      Name: jumpServerVmName
    }, combineResourceTags)
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: vmUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: storageProfilePublisher
        offer: storageProfileOffer
        sku: storageProfileSku
        version: storageProfileVersion
      }
      osDisk: {
        name: jumpServerVmOsDiskName
        createOption: osDiskCreateOption
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumpSeverVmNetworkInterface.id
        }
      ]
    }
  }
}
