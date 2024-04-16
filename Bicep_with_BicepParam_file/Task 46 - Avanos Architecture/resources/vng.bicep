param values object 
param publicId string
param subnetId string






resource vng 'Microsoft.Network/virtualNetworkGateways@2023-05-01' = {
  name: values.vngname
  location: values.hublocation 
  properties: {
    activeActive: values.disable
    gatewayType: values.gatewaytype
    enableBgp: false 
    ipConfigurations: [
       {
          name: 'ipconfig'
          properties: {
             privateIPAllocationMethod: 'Dynamic'
             publicIPAddress: {
               id: publicId
             } 
             subnet: {
               id: subnetId
             } 
          } 
       }
    ] 
    sku: {
        name: values.tier
        tier: values.tier
    }
    vpnType: values.vpntype
    vpnGatewayGeneration: values.generation        
  }
}
