param vnetname string
param location string
param addressprefix string
param subnetname string
param subnetprefix string
param publicipname string
param vngname string
param disable bool
param gatewaytype string
param tier string
param vpntype string
param generation string

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetname
  parent: vnet
  properties: {
     addressPrefix: subnetprefix
  }  
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: publicipname
  location: location
  sku: {
    name:  'Standard'
  }
  properties: {
    publicIPAllocationMethod:  'Static'
    publicIPAddressVersion: 'IPv4' 
  }
  zones: [
     1
     2
     3
  ]
}

resource vng 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: vngname
  location: location 
  properties: {
    activeActive: disable
    gatewayType: gatewaytype
    enableBgp: false 
    ipConfigurations: [
       {
          name: 'ipconfig'
          properties: {
             privateIPAllocationMethod: 'Dynamic'
             publicIPAddress: {
               id: publicIpAddress.id
             } 
             subnet: {
               id: subnet.id
             } 
          } 
       }
    ] 
    sku: {
        name: tier
        tier: tier
    }
    vpnType: vpntype
    vpnGatewayGeneration: generation        
  }
}
