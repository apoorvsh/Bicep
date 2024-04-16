@description('Tags for the resoruces')
param resourceTags object
@description('Resource Location')
param location string
@description('Availablity Set Name')
param name string

var platformFaultDomainCount = 2
var platformUpdateDomainCount = 5

resource availabilitySetName_resource 'Microsoft.Compute/availabilitySets@2023-07-01' = {
  name: name
  location: location
  tags: resourceTags
  properties: {
    platformFaultDomainCount: platformFaultDomainCount
    platformUpdateDomainCount: platformUpdateDomainCount
  }
  sku: {
    name: 'aligned'
  }
}

output availabilitySetId string = availabilitySetName_resource.id
