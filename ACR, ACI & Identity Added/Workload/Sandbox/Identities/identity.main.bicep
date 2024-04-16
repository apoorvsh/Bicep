targetScope = 'subscription'

param environment string
param domainName string
@description('Resource Group Name')
param resourceGroupName string
param location string
param resourceTags object
var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}

var resourceNames = {
  identityName: toLower('${environment}-${locationMap[location]}-${domain}-acr')
}

module resourceGroup_Creation '../../../Modules/Resource Group/resource_group.mod.bicep' = {
  name: resourceGroupName
  params: {
    location: location
    name: resourceGroupName
    resourceTags: resourceTags
  }
}

module identity '../../../Modules/Identities/identity.bicep' = {
  name: 'deploy-identity'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    identityName: resourceNames.identityName
    location: location
  }
}
