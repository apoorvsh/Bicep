param values object


resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: values.azurepublicIpname
  location: values.location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

output firewallIP string = publicIpAddress.id
