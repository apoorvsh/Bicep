@description('Route Table Name')
param name string
@description('Tags for the resources')
param resourceTags object
@description('Route table Routes Configurations')
param routes array
@description('Resource Location')
param location string

// variables
@description('Allow Bgp Route Propagation')
var disableBgpRoutePropagation = true

// creation of User Defined Routes
resource routeTable 'Microsoft.Network/routeTables@2023-05-01' = {
  name: name
  location: location
  tags: resourceTags
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: routes
  }
}
