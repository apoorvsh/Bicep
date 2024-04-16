targetScope = 'subscription'

@description('Resource Group Name')
param name string
@description('Resource Location')
param location string
@description('Tags for the resources')
param resourceTags object

resource resourceGroup_resource 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: toLower(name)
  location: location
  tags: resourceTags
}
