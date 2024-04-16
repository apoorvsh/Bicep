param value object





resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: value.publicIpName[0]
  location: value.location
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

output publicipid string = publicIp.id
