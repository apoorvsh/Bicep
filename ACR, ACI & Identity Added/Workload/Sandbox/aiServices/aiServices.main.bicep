targetScope = 'subscription'

@description('Location for the all the Azure Services')
param location string = deployment().location
@description('Tags for the resoruces')
param resourceTags object
param environment string
param domainName string
@description('Resource Group Name')
param resourceGroupName string
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
@description('Network Access Public or Private')
@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string
@description('Private DNS Zone IDS')
param privateZoneDnsID array
@description('Cognitive Service is already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false"')
@allowed([
  true
  false ])
param cognitiveServiceRestore bool 
@description('Lets you create, read, update, delete and manage keys of Cognitive Services.')
param aiCognitiveServiceAccessADGroupObjectId string
@description('Full access including the ability to fine-tune, deploy and generate text')
param openAiAccessADGroupObjectId string

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}

var resourceNames = {
  aiSearchName: toLower('${environment}-${locationMap[location]}-${domain}-search01')
  openAIName: toLower('${environment}-${locationMap[location]}-${domain}-openai01')
  aiMultiServiceaAccountName: toLower('${environment}-${locationMap[location]}-${domain}-msaccount01')
  privateEndpointName: [
    toLower('${environment}-${locationMap[location]}-${domain}-pv-searchService01')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-account01')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-account02')
  ]
  privateEndpointNicNames: [
    toLower('${environment}${locationMap[location]}${domain}nicsearchService01')
    toLower('${environment}${locationMap[location]}${domain}nicaccount01')
    toLower('${environment}${locationMap[location]}${domain}nicaccount02')
  ]
}

var groupIds = [for config in resourceID: config == existing_Ai_Search.id ? 'searchService' : 'account']
var resourceID = [
  existing_Ai_Search.id
  existing_OpenAI.id
  existing_Ai_Service.id
]

resource existing_Ai_Search 'Microsoft.Search/searchServices@2023-11-01' existing = {
  name: resourceNames.aiSearchName
  scope: resourceGroup(resourceGroup_Creation.name)
}

resource existing_OpenAI 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: resourceNames.openAIName
  scope: resourceGroup(resourceGroup_Creation.name)
}

resource existing_Ai_Service 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: resourceNames.aiMultiServiceaAccountName
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

module ai_Search '../../../Modules/AI Search/aiSearch.mod.bicep' = {
  name: 'deploy-aiSearch'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    aiSearchName: resourceNames.aiSearchName
    location: location
    resourceTags: resourceTags
    networkAccessApproach: networkAccessApproach
  }
}

module ai_Search_Diagnostic '../../../Modules/AI Search/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-aiSearch-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    aiSearchName: resourceNames.aiSearchName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    ai_Search
  ]
}

module openAI '../../../Modules/OpenAI/openAI.mod.bicep' = {
  name: 'deploy-openAI'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.openAIName
    location: location
    resourceTags: resourceTags
    networkAccessApproach: networkAccessApproach
    cognitiveServiceRestore: cognitiveServiceRestore
  }
}

module openAI_Contributor_Role '../../../Modules/OpenAI/openAI_contributor.mod.bicep' = {
  name: 'deploy-openAIContributor-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.openAIName
    openAiAccessADGroupObjectId: openAiAccessADGroupObjectId
  }
  dependsOn: [
    openAI
  ]
}

module openAI_Diagnostic '../../../Modules/OpenAI/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-openAI-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.openAIName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    openAI
  ]
}

module ai_Multi_Service_Account '../../../Modules/AI Service Multi Service Account/ai_Service_Account.bicep' = {
  name: 'deploy-aiMultiServiceAccount'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.aiMultiServiceaAccountName
    location: location
    resourceTags: resourceTags
    networkAccessApproach: networkAccessApproach
    cognitiveServiceRestore: cognitiveServiceRestore
  }
}

module cognitive_service_contributor '../../../Modules/AI Service Multi Service Account/cognitive_service_contributor.mod.bicep' = {
  name: 'deploy-cogntiveServiceContributor-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.aiMultiServiceaAccountName
    aiCognitiveServiceAccessADGroupObjectId: aiCognitiveServiceAccessADGroupObjectId
  }
  dependsOn: [
    ai_Multi_Service_Account
  ]
}

module ai_Multi_Service_Account_Diagnostic '../../../Modules/AI Service Multi Service Account/diagnostic.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-aiMultiServiceAccount-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.aiMultiServiceaAccountName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    ai_Multi_Service_Account
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
    resourceID: resourceID
  }
  dependsOn: [
    ai_Search, openAI, ai_Multi_Service_Account
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
