param value object 





resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: value.publicIpName[1]
  location: value.hublocation
  sku: {
    name: value.publicIpSku
  }
  properties: {
    publicIPAllocationMethod: value.publicIPAllocationMethod
    
  }
  zones: [
    '1'
    '2'
    '3'
  ] 
}

output hubPublicIp string = publicIp.id
