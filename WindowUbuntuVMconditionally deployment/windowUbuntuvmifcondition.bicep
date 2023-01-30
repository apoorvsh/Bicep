param vnetName string
param vnetAddress string
param vnetTagName object
param subnetNameA string
param subnetAddressA string
param subnetNameB string
param subnetAddressB string
param windowNicName string
param windowNicTagName object
param windowSubnet string
param ubuntuSubnet string
param windowIpConfigurationsName string
param windowPrivateIpAllocationMethod string
param ubuntuNicName string
param ubuntuNicTagName object
param ubuntuIpConfigurationsName string
param ubuntuPrivateIpAllocationMethod string
param windowNsgName string
param windowNsgTagName object
param windowNsgRuleName string
param windowNsgDiscription string
param windowNsgProtocol string
param windowNsgSourcePortRange string
param windowNsgDestinationPortRange string
param windowNsgSourceAddressPrefix string
param windowNsgdestinationAddressPrefix string
param windowNsgAccess string
param windowNsgPriority int
param windowNsgdirection string
param ubuntuNsgName string
param ubuntuNsgTagName object
param ubuntuNsgRuleName string
param ubuntuNsgDiscription string
param ubuntuNsgProtocol string
param ubuntuNsgSourcePortRange string
param ubuntuNsgDestinationPortRange string
param ubuntuNsgSourceAddressPrefix string
param ubuntuNsgDestinationAddressPrefix string
param ubuntuNsgAccess string
param ubuntuNsgPriority int
param ubuntuNsgdirection string
param windowPublicIpName string
param windowPublicIpTagName object
param windowPublicIPAllocationMethod string
param ubuntuPublicIpName string
param ubuntuPublicIpTagName object
param ubuntuPublicIpAllocationMethod string
param windowVmName string
param windowVmTagName object
param windowVmSize string
var windowComputerName = 'WindowVM'
var windowAdminUserName = 'testuser'
var windowAdminPassword = 'Password@123'
param windowPublisher string
param windowStorageProfileOffer string
param windowStorageProfileSku string
param windowStorageProfileVersion string
param windowOsDiskName string
param windowOsDiskCaching string
param windowOsDiskCreateOption string
param ubuntuVmName string
param ubuntuVmTagName object
param ubuntuVmSize string
var ubuntuComputerName = 'UbuntuVM'
var ubuntuAdminUserName = 'testuser'
var ubuntuAdminPassword = 'Password@123'
param ubuntuPublisher string
param ubuntuStorageProfileOffer string
param ubuntuStorageProfileSku string
param ubuntuStorageProfileVersion string
param ubuntuOsDiskName string
param ubuntuOsDiskCaching string
param ubuntuOsDiskCreateOption string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags:vnetTagName.tagA
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
  }
}

resource subnetA 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: subnetNameA
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddressA
    networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
  }
}

resource subnetB 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: subnetNameB
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddressB
    networkSecurityGroup: {
            id: networkSecurityGroup1.id
          }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: windowNicName
  location: resourceGroup().location
  tags: windowNicTagName.tagA
  properties: {
    ipConfigurations: [
      {
        name: windowIpConfigurationsName
        properties: {
          privateIPAllocationMethod: windowPrivateIpAllocationMethod
          publicIPAddress: {
            id: publicip.id
          }
          subnet: {
            id: subnetA.id
          }
        }
      }
    ]
  }
}

resource networkInterface1 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: ubuntuNicName
  location: resourceGroup().location
  tags: ubuntuNicTagName.tagA
  properties: {
    ipConfigurations: [
      {
        name: ubuntuIpConfigurationsName
        properties: {
          privateIPAllocationMethod: ubuntuPrivateIpAllocationMethod
          publicIPAddress: {
            id: publicip1.id
          }
          subnet: {
            id: subnetB.id
          }
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: windowNsgName
  location: resourceGroup().location
  tags: windowNsgTagName.tagA
  properties: {
    securityRules: [
      {
        name: windowNsgRuleName
        properties: {
          description: windowNsgDiscription
          protocol: windowNsgProtocol
          sourcePortRange: windowNsgSourcePortRange
          destinationPortRange: windowNsgDestinationPortRange
          sourceAddressPrefix: windowNsgSourceAddressPrefix
          destinationAddressPrefix: windowNsgdestinationAddressPrefix
          access: windowNsgAccess
          priority: windowNsgPriority
          direction: windowNsgdirection
        }
      }
    ]
  }
}

resource networkSecurityGroup1 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: ubuntuNsgName
  location: resourceGroup().location
  tags: ubuntuNsgTagName.tagA
  properties: {
    securityRules: [
      {
        name: ubuntuNsgRuleName
        properties: {
          description: ubuntuNsgDiscription
          protocol: ubuntuNsgProtocol
          sourcePortRange: ubuntuNsgSourcePortRange
          destinationPortRange: ubuntuNsgDestinationPortRange
          sourceAddressPrefix: ubuntuNsgSourceAddressPrefix
          destinationAddressPrefix: ubuntuNsgDestinationAddressPrefix
          access: ubuntuNsgAccess
          priority: ubuntuNsgPriority
          direction: ubuntuNsgdirection
        }
      }
    ]
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name:  windowPublicIpName
  location: resourceGroup().location
  tags: windowPublicIpTagName.tagA
  properties: {
    publicIPAllocationMethod: windowPublicIPAllocationMethod
  }
} 

resource publicip1 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name:  ubuntuPublicIpName
  location: resourceGroup().location
  tags: ubuntuPublicIpTagName.tagA
  properties: {
    publicIPAllocationMethod: ubuntuPublicIpAllocationMethod
  }
} 

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = if (windowSubnet == subnetNameA) {
  name: windowVmName
  location: resourceGroup().location
  tags: windowVmTagName.tagA
  properties: {
    hardwareProfile: {
      vmSize: windowVmSize
    }
    osProfile: {
      computerName: windowComputerName
      adminUsername: windowAdminUserName
      adminPassword: windowAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: windowPublisher
        offer: windowStorageProfileOffer
        sku: windowStorageProfileSku
        version: windowStorageProfileVersion
      }
      osDisk: {
        name: windowOsDiskName
        caching: windowOsDiskCaching
        createOption: windowOsDiskCreateOption
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
}

resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = if (ubuntuSubnet == subnetNameB) {
  name: ubuntuVmName
  location: resourceGroup().location
  tags: ubuntuVmTagName.tagA
  properties: {
    hardwareProfile: {
      vmSize: ubuntuVmSize
    }
    osProfile: {
      computerName: ubuntuComputerName
      adminUsername: ubuntuAdminUserName
      adminPassword: ubuntuAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: ubuntuPublisher
        offer: ubuntuStorageProfileOffer
        sku: ubuntuStorageProfileSku
        version: ubuntuStorageProfileVersion
      }
      osDisk: {
        name: ubuntuOsDiskName
        caching: ubuntuOsDiskCaching
        createOption: ubuntuOsDiskCreateOption
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
        }
      ]
    }
  }
}

