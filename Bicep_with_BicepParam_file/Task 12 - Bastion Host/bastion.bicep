param location string 
param publicIpAddressName string = 'myPublicIP'
param vnetName string = 'myVNet'
param vnetIpPrefix string = '10.2.0.0/16'
param bastionSubnetName string = 'BastionSubnet'
param bastionSubnetIpPrefix string = '10.2.1.0/26'
param bastionHostName string
param nsgName string = 'BastionNSG'



resource bastion 'Microsoft.Network/bastionHosts@2023-04-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
       {
         name: 'ipconfig1'
         properties: {
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

resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpAddressName
  location: location
  sku: {
     name:  'Standard'
  }
  properties: {
     publicIPAllocationMethod: 'Static'
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName 
  location: location
  properties: {
     securityRules: [
       {
         name: 'http'
         properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
         }
       }
        {
           name: 'GatewayManager'
           properties: {
            protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
           }
        }
         {
          name: 'AllowLoadBalancerInBound'
          properties: {
            protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
          }
         }
         {
          name: 'AllowBastionHostCommunicationInBound'
          properties: {
            protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: ['8080', '5701']
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
          }
         }
         {
          name: 'DenyAllInBound'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationPortRange: '*'
            destinationAddressPrefix: '*'
            access: 'Deny'
            priority: 1000
            direction: 'Inbound'
          }
        }
        {
          name: 'AllowSshRdpOutBound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationPortRanges: ['22', '3389']
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 100
            direction: 'Outbound'
          }
        }
        {
          name: 'AllowAzureCloudCommunicationOutBound'
          properties: {
            protocol: 'Tcp'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationPortRange: '443'
            destinationAddressPrefix: 'AzureCloud'
            access: 'Allow'
            priority: 110
            direction: 'Outbound'
          }
        }
        {
          name: 'AllowBastionHostCommunicationOutBound'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            sourceAddressPrefix: 'VirtualNetwork'
            destinationPortRanges: ['8080', '5701']
            destinationAddressPrefix: 'VirtualNetwork'
            access: 'Allow'
            priority: 120
            direction: 'Outbound'
          }
        }
        {
          name: 'AllowGetSessionInformationOutBound'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationAddressPrefix: 'Internet'
            destinationPortRanges: ['80', '443']
            access: 'Allow'
            priority: 130
            direction: 'Outbound'
          }
        }
        {
          name: 'DenyAllOutBound'
          properties: {
            protocol: '*'
            sourcePortRange: '*'
            sourceAddressPrefix: '*'
            destinationPortRange: '*'
            destinationAddressPrefix: '*'
            access: 'Deny'
            priority: 1000
            direction: 'Outbound'
          }
        }
     ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
     addressSpace:  {
       addressPrefixes: [
        vnetIpPrefix
       ]
     }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: bastionSubnetName
  parent: vnet
  properties: {
    addressPrefix: bastionSubnetIpPrefix
    networkSecurityGroup: {
       id: nsg.id
    }
  }
}
