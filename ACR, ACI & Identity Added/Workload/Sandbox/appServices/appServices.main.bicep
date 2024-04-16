targetScope = 'subscription'

@description('Location for the all the Azure Services')
param location string = deployment().location
@description('Tags for the resoruces')
param resourceTags object
@description('Resource Group Name')
param resourceGroupName string
param environment string
param domainName string
@description('App Service Plan Sku Type')
@allowed([
  'Basic'
  'Standard'
  'PremiumV2'
  'PremiumV3'
])
param appServiceSkuVersion string
@description('App Serive OS Version')
@allowed([
  'Linux'
  'Window'
])
param appServiceOsVersion string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param pvSubnetName string
@description('App Services Subnet Name')
param appSubnetName string
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
@description('Network Access Public or Private')
@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string
@description('Private DNS Zone IDS')
param privateZoneDnsID array
@description('Read, write, and delete Azure Storage containers and blobs.')
param storageAccessADGroupObjectId string = ''
param publisherName string = 'Contoso'
param publisherEmail string = 'apim@contoso.com'
@allowed([
  'Internal'
  'External'
])
param virtualNetworkType string
param apimSubnetName string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool = true
@description('Can manage service and the APIs')
param apimAccessADGroupObjectId string
@description('Manage websites, but not web plans. Does not allow you to assign roles in Azure RBAC.')
param funAppAccessADGroupObjectId string
@description('If already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false", "Only API Management services deleted within the last 48 hours can be recovered."')
param apimRestore bool = false

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}

var resourceNames = {
  appServicePlanName: toLower('${environment}-${locationMap[location]}-${domain}-plan01')
  functionAppName: toLower('${environment}-${locationMap[location]}-${domain}-funapp01')
  publicIpName: toLower('${environment}-${locationMap[location]}-${domain}-pip02')
  apimName: toLower('${environment}-${locationMap[location]}-${domain}-apim02')
  appInsightName: toLower('${environment}-${locationMap[location]}-${domain}-appInsight01')
  storageAccountName: take(toLower('${environment}${locationMap[location]}${domain}str02'), 24)
  privateEndpointName: [
    toLower('${environment}-${locationMap[location]}-${domain}-pv-sites01')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-gateway01')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-blob02')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-file02')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-table02')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-queue02')
  ]
  privateEndpointNicNames: [
    toLower('${environment}${locationMap[location]}${domain}nicsites01')
    toLower('${environment}${locationMap[location]}${domain}nicgateway01')
    toLower('${environment}${locationMap[location]}${domain}nicblob02')
    toLower('${environment}${locationMap[location]}${domain}nicfile02')
    toLower('${environment}${locationMap[location]}${domain}nictable02')
    toLower('${environment}${locationMap[location]}${domain}nicqueue02')
  ]
}
var groupIds = [
  'sites'
  'Gateway'
  'blob'
  'file'
  'table'
  'queue'
]

var resouceID = [for groupID in groupIds: contains(groupID, 'sites') && groupID == 'sites' ? existing_Function_App.id : contains(groupID, 'Gateway') && groupID == 'Gateway' ? existing_Apim.id : existing_Storage.id]

resource existing_Function_App 'Microsoft.Web/sites@2022-09-01' existing = {
  name: resourceNames.functionAppName
  scope: resourceGroup(resourceGroup_Creation.name)
}

resource existing_Apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: resourceNames.apimName
  scope: resourceGroup(resourceGroup_Creation.name)
}

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
  name: 'deploy-storage'
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

module storage_Blob_Data_Contributor '../../../Modules/Storage Account/storage_blob_data_contributor_roleassign.mod.bicep' = {
  name: 'deploy-storageBlobDataContributor-Role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    storageName: resourceNames.storageAccountName
    storageAccessADGroupObjectId: storageAccessADGroupObjectId
  }
  dependsOn: [
    storage_Account
  ]
}

module storage_diagnostic '../../../Modules/Storage Account/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'storage-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    storageAccountName: resourceNames.storageAccountName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    storage_Account
  ]
}

module app_Service_Plan '../../../Modules/App Service Plan/app_service_plan.bicep' = {
  name: 'deploy-appServicePlan'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    appServicePlanName: resourceNames.appServicePlanName
    location: location
    resourceTags: resourceTags
    appServiceOsVersion: appServiceOsVersion
    appServiceSkuVersion: appServiceSkuVersion
  }
  dependsOn: [
    storage_Account
  ]
}

module app_Service_Plan_Diagnostic '../../../Modules/App Service Plan/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'appServicePlan-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    appServicePlanName: resourceNames.appServicePlanName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    app_Service_Plan
  ]
}

module application_Insight '../../../Modules/Application Insight/application_insight.bicep' = {
  name: 'deploy-applicationInsight'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.appInsightName
    location: location
    resourceTags: resourceTags
    workspaceId: workspaceId
  }
}

module function_App '../../../Modules/Function App/function_app.bicep' = {
  name: 'deploy-functionApp'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    functionAppName: resourceNames.functionAppName
    location: location
    resourceTags: resourceTags
    applicationInsightInstrumentationKey: application_Insight.outputs.instrumentKey
    appServicePlanId: app_Service_Plan.outputs.appServicePlanId
    appServiceOsVersion: appServiceOsVersion
    vnetName: vnetName
    vnetResourceGroupName: vnetResourceGroupName
    appSubnetName: appSubnetName
    storageAccountName: resourceNames.storageAccountName
    networkAccessApproach: networkAccessApproach
  }
  dependsOn: [
    application_Insight, app_Service_Plan, storage_Account
  ]
}

module website_contributor '../../../Modules/Function App/web_site_contributor.mod.bicep' = {
  name: 'deploy-websiteContributor-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.functionAppName
    funAppAccessADGroupObjectId: funAppAccessADGroupObjectId
  }
  dependsOn: [
    function_App
  ]
}

module public_IP '../../../Modules/Network/public_IP.mod.bicep' = if (networkAccessApproach != 'Private') {
  name: 'deploy-publicIP'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.publicIpName
    location: location
    resourceTags: resourceTags
  }
}

module public_IP_Diagnostic '../../../Modules/Network/diagnostic.mod.bicep' = if (networkAccessApproach != 'Private' && (enableDiagnosticSetting)) {
  name: 'deploy-publicIP-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    workspaceId: workspaceId
    publicIpName: resourceNames.publicIpName
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    public_IP
  ]
}

module apim '../../../Modules/APIM/apim.mod.bicep' = {
  name: 'deploy-apim'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    apiManagementName: resourceNames.apimName
    location: location
    resourceTags: resourceTags
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: virtualNetworkType
    networkAccessApproach: networkAccessApproach
    vnetResourceGroupName: vnetResourceGroupName
    vnetName: vnetName
    apimSubnetName: apimSubnetName
    publicIpId: !empty(virtualNetworkType) && contains(networkAccessApproach, 'Public') ? public_IP.outputs.publicIpID : ''
    appInsightsName: resourceNames.appInsightName
    appInsightsId: application_Insight.outputs.applicationInsightId
    appInsightsInstrumentationKey: application_Insight.outputs.instrumentKey
    apimRestore: apimRestore
  }
  dependsOn: [
    public_IP, application_Insight
  ]
}

module apim_Management_Service_Contributor_Role '../../../Modules/APIM/api_management_service_contributor_mod.bicep' = {
  name: 'deploy-apimContributor-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.apimName
    apimAccessADGroupObjectId: apimAccessADGroupObjectId
  }
  dependsOn: [
    apim
  ]
}

module apim_Diagnostic_Setting '../../../Modules/APIM/diagnostic.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-apim-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    apimName: resourceNames.apimName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    apim
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
    apim, function_App
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
