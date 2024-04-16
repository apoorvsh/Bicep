targetScope = 'subscription'

@description('Location for the all the Azure Services')
param location string = deployment().location
@description('Tags for the resoruces')
param resourceTags object
@description('Resource Group Name')
param resourceGroupName string
param environment string
param domainName string
@description('Network Access Public or Private')
@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string
@description('container inside storage account')
param containers object = {}
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
@description('Storage Account Sku')
param storageAccountSku string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param pvSubnetName string
@description('Private DNS Zone IDS')
param privateZoneDnsID array
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Read, write, and delete Azure Storage containers and blobs.')
param storageAccessADGroupObjectId string = ''
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool = true

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}
var resourceNames = {
  storageAccountName: take(toLower('${environment}${locationMap[location]}${domain}logstr01'), 24)
  privateEndpointName: [
    toLower('${environment}-${locationMap[location]}-${domain}-pv-blob01')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-file01')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-table01')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-queue01')
  ]
  privateEndpointNicNames: [
    toLower('${environment}${locationMap[location]}${domain}nicblob01')
    toLower('${environment}${locationMap[location]}${domain}nicfile01')
    toLower('${environment}${locationMap[location]}${domain}nictable01')
    toLower('${environment}${locationMap[location]}${domain}nicqueue01')
  ]
}
var groupIds = [
  'blob'
  'file'
  'table'
  'queue'
]

var resouceID = [for groupId in groupIds: existing_Storage.id]

resource existing_Storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: resourceNames.storageAccountName
  scope: resourceGroup(resourceGroup_Creation.name)
}

module resourceGroup_Creation '../../../Modules/Resource Group/resource_group.mod.bicep' = {
  name: resourceGroupName
  params: {
    location: location
    name: resourceGroupName
    resourceTags: resourceTags
  }
}

module storage_Account '../../../Modules/Storage Account/storage_account.mod.bicep' = {
  name: 'deploy-storageAccount'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    storageAccountSku: storageAccountSku
    storageAccountName: resourceNames.storageAccountName
    location: location
    resourceTags: resourceTags
    networkAccessApproach: networkAccessApproach
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
  }
}

module storage_Container '../../../Modules/Storage Account/container.mod.bicep' = if (contains(containers, 'container') && !empty(containers)) {
  name: 'deploy-storageAccount-containers'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    container: containers.container
    storageAccountName: resourceNames.storageAccountName
  }
  dependsOn: [
    storage_Account
  ]
}

module storage_Blob_Data_Contributor_Role '../../../Modules/Storage Account/storage_blob_data_contributor_roleassign.mod.bicep' = {
  name: 'deploy-storageBlobDataContributor-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    storageName: resourceNames.storageAccountName
    storageAccessADGroupObjectId: storageAccessADGroupObjectId
  }
  dependsOn: [
    storage_Account
  ]
}

module storage_Diagnostic '../../../Modules/Storage Account/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-storageAccount-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    storageAccountName: resourceNames.storageAccountName
    workspaceId: workspaceId
  }
  dependsOn: [
    storage_Account
  ]
}

module private_Endpoint '../../../Modules/Network/private_endpoint.mod.bicep' = if (networkAccessApproach != 'Public') {
  name: 'deploy-privateEndpoint'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    privateEndpointName: resourceNames.privateEndpointName
    privateEndpointNicNames: resourceNames.privateEndpointNicNames
    location: location
    resourceTags: resourceTags
    vnetResourceGroupName: vnetResourceGroupName
    vnetName: vnetName
    pvSubnetName: pvSubnetName
    groupIDs: groupIds
    resourceID: resouceID
  }
  dependsOn: [
    storage_Account
  ]
}

module private_Dns_Zone_Group '../../../Modules/Network/private_dns_zone_group.mod.bicep' = if (networkAccessApproach != 'Public') {
  name: 'deploy-privateDnsZoneGroup'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    privateEndpointName: resourceNames.privateEndpointName
    privateDnsZoneID: privateZoneDnsID
  }
  dependsOn: [
    private_Endpoint
  ]
}
