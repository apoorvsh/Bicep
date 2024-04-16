targetScope = 'subscription'

@description('Location for the all the Azure Services')
param location string = deployment().location
@description('Tags for the resoruces')
param resourceTags object
@description('Resource Group Name')
param resourceGroupName string
param environment string
param domainName string
@description('If customer wants to create new virtual network using bicep scripts the set "new" or if the virtual network in exsiting already deployed on Azure manually then set "existing"')
@allowed([
    'new'
    'existing'
  ]
)
param newOrExisting string
@description('Existing Virtual Network Name')
param existingVnetName string
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('New Virtual Address Space')
param vnetAddressSpace array
param routeTableRoutes array
param subnetAddressPrefix object
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}
var resourceNames = {
  routeTableName: toLower('${environment}-${locationMap[location]}-${domain}-rt01')
  vnetName: toLower('${environment}-${locationMap[location]}-${domain}-vnet01')
  nsgName: [
    toLower('${environment}-${locationMap[location]}-${domain}-nsg-compute01')
    toLower('${environment}-${locationMap[location]}-${domain}-nsg-data01')
    toLower('${environment}-${locationMap[location]}-${domain}-nsg-app01')
    toLower('${environment}-${locationMap[location]}-${domain}-nsg-apim01')
  ]
  subnetNames: [
    toLower('${environment}-${locationMap[location]}-${domain}-snet-compute01')
    toLower('${environment}-${locationMap[location]}-${domain}-snet-data01')
    toLower('${environment}-${locationMap[location]}-${domain}-snet-app01')
    toLower('${environment}-${locationMap[location]}-${domain}-snet-apim01')
  ]
}
var subnets = [
  {
    subnetName: resourceNames.subnetNames[0]
    subentAddressPrefix: subnetAddressPrefix.compute
    nsgName: resourceNames.nsgName[0]
    routeTableName: resourceNames.routeTableName
    serviceEndpoints: []
    delegations: []

  }
  {
    subnetName: resourceNames.subnetNames[1]
    subentAddressPrefix: subnetAddressPrefix.data
    nsgName: resourceNames.nsgName[1]
    routeTableName: resourceNames.routeTableName
    serviceEndpoints: []
  }
  {
    subnetName: resourceNames.subnetNames[2]
    subentAddressPrefix: subnetAddressPrefix.app
    nsgName: resourceNames.nsgName[2]
    routeTableName: resourceNames.routeTableName
    delegations: [
      {
        name: 'Microsoft.Web/serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
  {
    subnetName: resourceNames.subnetNames[3]
    subentAddressPrefix: subnetAddressPrefix.apim
    nsgName: resourceNames.nsgName[3]
    routeTableName: resourceNames.routeTableName
  }

]

module resourceGroup_Creation '../../../Modules/Resource Group/resource_group.mod.bicep' = if (contains(newOrExisting, 'new')) {
  name: resourceGroupName
  params: {
    location: location
    name: resourceGroupName
    resourceTags: resourceTags
  }
}

module route_Table '../../../Modules/Network/route_table.mod.bicep' = {
  name: 'deploy-routeTable'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.routeTableName
    location: location
    routes: routeTableRoutes
    resourceTags: resourceTags
  }
}

module network_Security_Group '../../../Modules/Network/network_security_group.mod.bicep' = {
  name: 'deploy-networkSecurityGroup'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.nsgName
    location: location
    resourceTags: resourceTags
  }
}

module vnet_Subnet '../../../Modules/Network/vnet_subnet.mod.bicep' = {
  name: 'deploy-vnetSubnet'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    existingVnetName: existingVnetName
    subnets: subnets
    routeTableName: resourceNames.routeTableName
    location: location
    newVnetName: resourceNames.vnetName
    newOrExistingVnetDeployment: newOrExisting
    resourceTags: resourceTags
    vnetAddressSpace: vnetAddressSpace
  }
  dependsOn: [
    route_Table, network_Security_Group
  ]
}

module network_Diagnostic '../../../Modules/Network/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-network-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    vnetName: newOrExisting != 'new' ? existingVnetName : resourceNames.vnetName
    nsgName: resourceNames.nsgName
    workspaceId: workspaceId
  }
  dependsOn: [
    route_Table, network_Security_Group, vnet_Subnet
  ]
}
