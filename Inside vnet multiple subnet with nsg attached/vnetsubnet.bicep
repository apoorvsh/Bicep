param vnetName string
param vnetTagName object
param vnetAddressSpace string
param subnets object
param nsgName string
param nsgTagName object
param nsgRuleName string
param nsgProtocol string
param nsgSourcePortRange string
param nsgDestinationPortRange string
param nsgSourceAddressPrefix string
param nsgDestinationAddressPrefix string
param nsgAccess string
param nsgPriority int
param nsgDirection string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: vnetTagName.tagA
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }   
  }
}

resource subnet 'Microsoft.Network/virtualnetworks/subnets@2015-06-15'= [for sub in items(subnets):{
  name: sub.value.SubnetName
  parent: virtualNetwork  
  properties: {
    addressPrefix: sub.value.SubnetAddress
     networkSecurityGroup: {
            id: networkSecurityGroup.id
         }
      }
} ]

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: nsgName
  location: resourceGroup().location
  tags: nsgTagName.tagA
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

