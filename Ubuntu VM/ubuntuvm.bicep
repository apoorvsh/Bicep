param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param nicName string
param ubuntuNicTagName object
param nsgName string
param ubuntuNsgTagName object
param privateIpAllocationMethod string
param nsgRuleName string
param nsgProtocol string
param nsgSourcePortRange string
param nsgDestinationPortRange string
param nsgsourceAddressPrefix string
param nsgDestinationAddressPrefix string
param nsgAccess string
param nsgPriority int 
param nsgDirection string
param publicIpName string
param ubuntuPublicIpTagName object
param publicIpAllocationMethod string
param ubuntuVmName string
param ubuntuVmTagName object
param ubuntuVmSize string
param osProfileComputerName string
@secure()
param ubuntuAdminUserName string
@secure()
param ubuntuAdminPassword string
param storageProfilePublisher string
param storageProfileOffer string
param storageProfileSku string
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
  tags: ubuntuNicTagName.tagA
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
  tags: ubuntuNsgTagName.tagA
  properties: {
    securityRules: [
      {
        name: nsgRuleName
        properties: {
          description: 'description'
          protocol: nsgProtocol
          sourcePortRange: nsgSourcePortRange
          destinationPortRange: nsgDestinationPortRange
          sourceAddressPrefix: nsgsourceAddressPrefix
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
  tags: ubuntuPublicIpTagName.tagA
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
} 

resource UbuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: ubuntuVmName
  location: resourceGroup().location
  tags: ubuntuVmTagName.tagA
  properties: {
    hardwareProfile: {
      vmSize: ubuntuVmSize
    }
  osProfile: {
    computerName: osProfileComputerName
    adminUsername: ubuntuAdminUserName
    adminPassword: ubuntuAdminPassword
  }
    storageProfile: {
      imageReference: {
        publisher: storageProfilePublisher
        offer: storageProfileOffer
        sku: storageProfileSku
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

