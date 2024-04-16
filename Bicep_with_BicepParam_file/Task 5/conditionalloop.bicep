param networkSecurityGroupName string 
param location string 

param vnetAddressPrefix array 
param subnet1Name array 
param subnet2Name array 
param subnet1AddressPrefix array 
param subnet2AddressPrefix array 

param count int 

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 450
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' = [for i in range(0, count): {
  name: 'vnet${i}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefix[i]
    }
  }
}]

/*resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = [for (index, subnetName) in subnet1Name: {
  name: subnet1Name[index]
  dependsOn: [
    vnet
  ]
  properties: {
    addressPrefix: subnet1AddressPrefix[index]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}]

resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = [for (index, subnetName) in subnet2Name: {
  name: subnet2Name[index]
  dependsOn: [
    vnet
  ]
  properties: {
    addressPrefix: subnet2AddressPrefix[index]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}]*/

resource subnets1 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for (name, subnetname) in subnet1Name: {
  name: '${name}'
  parent: vnet[0]
  properties: {
    addressPrefix: subnet1AddressPrefix[subnetname]
    networkSecurityGroup: {
       id: networkSecurityGroupName == 'nsg01' ? nsg.id : null
    }
  }
  //dependsOn: vnet
}

]

resource subnets2 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for (name, subnetname) in subnet2Name: {
  name: '${name}'
  parent: vnet[1]
  properties: {
    addressPrefix: subnet2AddressPrefix[subnetname]
    networkSecurityGroup: {
      id: networkSecurityGroupName == 'nsg01' ? nsg.id : null
    }
  }
  //dependsOn: vnet
}

]


 
