@description('Virtual Network Name')
param newVnetName string
@description('Existing Virtual Network Name')
param existingVnetName string
@description('Tags for the resources')
param resourceTags object
param vnetAddressSpace array = []
@description('If customer wants to create new virtual network using bicep scripts the set "new" or if the virtual network in exsiting already deployed on Azure manually then set "existing"')
@allowed(
  [
    'new'
    'existing'
  ]
)
param newOrExistingVnetDeployment string
@description('Resource Location')
param location string
param routeTableName string
@description('Subnet Creation')
param subnets array

var vnetName = newOrExistingVnetDeployment == 'new' ? newVirtualNetwork.name : existingVirtualNetwork.name

// existing vnet that is already deployed on azure 
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' existing = if (newOrExistingVnetDeployment != 'new') {
  name: existingVnetName
}

resource existingNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = [for config in subnets: if (contains(config, 'nsgName')) {
  name: config.nsgName
}]

resource existingRouteTable 'Microsoft.Network/routeTables@2023-05-01' existing = if (!empty(routeTableName)) {
  name: routeTableName
}

resource newVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = if (newOrExistingVnetDeployment == 'new') {
  name: newVnetName
  location: location
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressSpace
    }
  }
  dependsOn: [
    existingRouteTable, existingNetworkSecurityGroup
  ]
}

@batchSize(1)
// creation of subnet
resource subnets_creation 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for (config, i) in subnets: {
  name: '${vnetName}/${config.subnetName}'
  properties: {
    addressPrefix: config.subentAddressPrefix
    networkSecurityGroup: contains(config, 'nsgName') && !empty(config.nsgName) ? {
      id: existingNetworkSecurityGroup[i].id
    } : null
    routeTable: contains(config, 'routeTableName') && !empty(config.routeTableName) ? {
      id: existingRouteTable.id
    } : null
    delegations: contains(config, 'delegations') && !empty(config.delegations) ? config.delegations : null
    serviceEndpoints: contains(config, 'serviceEndpoints') && !empty(config.serviceEndpoints) ? config.serviceEndpoints : null
  }
  dependsOn: [
    existingRouteTable, existingNetworkSecurityGroup
  ]
}]
