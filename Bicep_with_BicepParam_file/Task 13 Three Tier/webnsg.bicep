param location string = 'Central India'
param vnetname string = 'vnet'
param addressprefix string = '10.0.0.0/16'
param subnetname string = 'subnet'
param subnetprefix string = '10.0.0.0/18'



resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' =  {
  name: vnetname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressprefix
      ]
    }
  }
  
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' =  {
  name:  subnetname
  parent: vnet
  properties: {
     addressPrefix: subnetprefix
     networkSecurityGroup: {
       id: webnsgID.id
     }
  }
}

resource webnsgID  'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'webnsg'
  location: location
  
  properties: {
    securityRules: [
      {
        name: 'allowrdp'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRanges: [
            '3389'
          ]
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      
      {
        name:'denydb'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          priority: 100
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
  
}
