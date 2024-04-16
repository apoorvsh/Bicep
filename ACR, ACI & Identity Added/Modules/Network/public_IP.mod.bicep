@description('Tags for the resoruces')
param resourceTags object
@description('Resource Location')
param location string
@description('Public IP Name')
param name string

@description('Allocation method for the Public IP used to access the Virtual Machine.')
/*@allowed([
  'Dynamic'
  'Static'
])*/
var publicIPAllocationMethod = 'Static'
@description('SKU for the Public IP used to access the Virtual Machine.')
/*@allowed([
  'Basic'
  'Standard'
])*/
var publicIpSku = 'Standard'
@description('Virtual Machine availabilty Zone')
var availabilityZones = '1'

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: name
  location: location
  tags: resourceTags
  sku: {
    name: publicIpSku
  }
  zones: [
    availabilityZones
  ]
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    /*dnsSettings: {
      domainNameLabel: config.dnsLabelPrefix
    }*/
  }
}

output publicIpID string = publicIp.id
