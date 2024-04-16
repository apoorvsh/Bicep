// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Next Hop of Ip Address')
param nextHopIpAddress string

// variables
var routeTableConfig = [
  {
    name: toLower('rt-${projectCode}-${environment}-compute01')
    routeName: 'rt-compute-to-all-01'
  }
  {
    name: toLower('rt-${projectCode}-${environment}-dbwhost01')
    routeName: 'rt-dbwhost-to-all-01'
  }
  {
    name: toLower('rt-${projectCode}-${environment}-dbwcon01')
    routeName: 'rt-dbwcon-to-all-01'
  }
  {
    name: toLower('rt-${projectCode}-${environment}-aap01')
    routeName: 'rt-aap-to-all-01'
  }
]
@description('Route Address Prefix')
var addressPrefix = '0.0.0.0/0'
@description('Route Next Hop Type')
var nextHopType = 'VirtualAppliance'
@description('Allow Bgp Route Propagation')
var disableBgpRoutePropagation = true

// creation of User Defined Routes
resource routeTable 'Microsoft.Network/routeTables@2022-07-01' = [for (config, i) in routeTableConfig: {
  name: config.name
  location: location
  tags: union({
      Name: config.name
    }, combineResourceTags)
  properties: {
    disableBgpRoutePropagation: disableBgpRoutePropagation
    routes: [
      {
        name: config.routeName
        properties: {
          addressPrefix: addressPrefix
          nextHopType: nextHopType
          nextHopIpAddress: nextHopIpAddress
        }
      }
    ]
  }
}]

// output of route table ids used in subnet.bicep
output computeSubnetRouteId string = routeTable[0].id
output hostSubnetRouteId string = routeTable[1].id
output containerSubnetRouteId string = routeTable[2].id
output appSubnetRouteId string = routeTable[3].id
