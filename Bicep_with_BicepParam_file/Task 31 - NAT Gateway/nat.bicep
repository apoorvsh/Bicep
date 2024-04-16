param publicipname string
param location string
param vnetname string
param vnetaddress string
param subnetname string
param subnetprefix string
param natgatewayname string




resource publicip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicipname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetname
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
         vnetaddress
       ]
     }
  }  
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetname
  parent: vnet
  properties: {
     addressPrefix: subnetprefix
     natGateway:  {
       id: natgateway.id
     }
  }   
}

resource natgateway 'Microsoft.Network/natGateways@2021-05-01' = {
  name: natgatewayname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicip.id
      }
    ]
  }
}
