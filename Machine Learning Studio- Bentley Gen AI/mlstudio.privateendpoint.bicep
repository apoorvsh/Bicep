@description('Tags for the resources')
param resourceTags object
@description('Resource Location')
param location string = resourceGroup().location
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param pvSubnetName string
@description('Resource ID for the particular services that we are creating private endpoint ')
param resourceID string
@description('Group ID "target sub resource" for the particular services that we are creating private endpoint ')
param groupIDs string
param privateEndpointNicNames string
param privateEndpointName string


resource privateEndpoint_creation 'Microsoft.Network/privateEndpoints@2023-05-01' =  {
  name: privateEndpointName
  location: location
  tags: resourceTags
  properties: {
    subnet: {
      id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${pvSubnetName}'
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceID
          groupIds: [
            groupIDs
          ]
        }
      }
    ]
    customNetworkInterfaceName: privateEndpointNicNames
  }
}
