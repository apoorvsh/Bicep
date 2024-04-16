@description('Tags for the resources')
param resourceTags object
@description('Resource Location')
param location string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param pvSubnetName string
@description('Resource ID for the particular services that we are creating private endpoint ')
param resourceID array
@description('Group ID "target sub resource" for the particular services that we are creating private endpoint ')
param groupIDs array
param privateEndpointNicNames array
param privateEndpointName array

@batchSize(1)
resource privateEndpoint_creation 'Microsoft.Network/privateEndpoints@2023-05-01' = [for i in range(0, length(privateEndpointName)): {
  name: privateEndpointName[i]
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${pvSubnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName[i]
        properties: {
          privateLinkServiceId: resourceID[i]
          groupIds: [
            groupIDs[i]
          ]
        }
      }
    ]
    customNetworkInterfaceName: privateEndpointNicNames[i]
  }
}]
