param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param nicName string
param windowNicTagName object
param nsgName string
param windowNsgTagName object
param privateIpAllocationMethod string
param nsgRuleName string
param nsgProtocol string
param nsgSourcePortRange string
param nsgDestinationPortRange string
param nsgSourceAddressPrefix string
param nsgDestinationAddressPrefix string
param nsgAccess string
param nsgPriority int
param nsgDirection string
param publicIpName string
param windowPulicIpTagName object
param publicIpAllocationMethod string
param windowVmName string
param windowVmTagName object
param windowVmSize string
param osProfileComputerName string
@secure()
param windowAdminUserName string
@secure()
param windowAdminPassword string
param storageProfilePublisher string
@allowed([
  'sql2019-ws2019'
  'sql2017-ws2019'
  'SQL2017-WS2016'
])
param storageProfileImageOffer string 
@allowed([
  'Standard'
  'Enterprise'
  'SQLDEV'
])
param storageProfileSqlSku string 
param storageProfileVersion string
param osDiskName string
param osDiskCaching string
param osDiskCreateOption string
param ipConfigName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: vnetTagName.tagA
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddress
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: resourceGroup().location
  tags: windowNicTagName.tagA
  properties: {
    ipConfigurations: [
      {
        name: ipConfigName
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

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgName
  location: resourceGroup().location
  tags: windowNsgTagName.tagA
  properties: {
    securityRules: [
      {
        name: nsgRuleName
        properties: {
          description: 'description'
          protocol: nsgProtocol
          sourcePortRange: nsgSourcePortRange
          destinationPortRange: nsgDestinationPortRange
          sourceAddressPrefix: nsgSourceAddressPrefix
          destinationAddressPrefix: nsgDestinationAddressPrefix
          access: nsgAccess
          priority: nsgPriority
          direction: nsgDirection
        }
      }
    ]
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name:  publicIpName
  location: resourceGroup().location
  tags: windowPulicIpTagName.tagA  
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
} 

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: windowVmName
  location: resourceGroup().location
  tags: windowVmTagName.tagA
  properties: {
    hardwareProfile: {
      vmSize: windowVmSize
    }
    osProfile: {
      computerName: osProfileComputerName
      adminUsername: windowAdminUserName
      adminPassword: windowAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: storageProfilePublisher
        offer: storageProfileImageOffer
        sku: storageProfileSqlSku
        version: storageProfileVersion
      }
      osDisk: {
        name: osDiskName
        caching: osDiskCaching
        createOption: osDiskCreateOption
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


 

