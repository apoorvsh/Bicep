targetScope = 'subscription'



param rgNames array




@description('Parameters of RG1')

param rg1ModuleName string
param addressPrefixRG1 array
param rg1Count int
param location array
param subnetNameRG1 array
param subnetPrefixRG1 array

param vnetNameRG1 array
@allowed([
  'YES'
  'NO'
])
param conditionRG1Nsg string

@allowed([
  'YES'
  'NO'
])
param conditionRG1Route string

param rg1RouteTableName array


param rg1NSGName array


@description('Parameters of RG2')

param rg2ModuleName string
param addressPrefixRG2 array
param rg2Count int

param subnetNameRG2 array
param subnetPrefixRG2 array

param vnetNameRG2 array
@allowed([
  'YES'
  'NO'
])
param conditionRG2Nsg string

@allowed([
  'YES'
  'NO'
])
param conditionRG2Route string


param rg2RouteTableName array


param rg2NSGName array

resource resourceGroup1 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgNames[0]
  location: location[0]
}

resource resourceGroup2 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgNames[1]
  location: location[1]
  dependsOn: [
    RG1
  ] 
}

module RG1 'RG1/file.bicep' = {
  scope: resourceGroup1
  name: rg1ModuleName
  params: {
    addressPrefix: addressPrefixRG1
    conditionNsg: conditionRG1Nsg
    conditionRouteTable: conditionRG1Route
    count: rg1Count
    location: location[0] 
    nsgName: rg1NSGName
    routeTableName: rg1RouteTableName
    subnetName: subnetNameRG1
    subnetPrefix: subnetPrefixRG1
    vnetName: vnetNameRG1
  }
}

module RG2 'RG2/file.bicep' = {
  scope: resourceGroup2
  name: rg2ModuleName
  params: {
    addressPrefix: addressPrefixRG2
    conditionNsg: conditionRG2Nsg
    conditionRouteTable: conditionRG2Route
    count: rg2Count
    location: location[1]
    nsgName: rg2NSGName  
    routeTableName: rg2RouteTableName
    subnetName: subnetNameRG2
    subnetPrefix: subnetPrefixRG2
    vnetName: vnetNameRG2
  }
}
