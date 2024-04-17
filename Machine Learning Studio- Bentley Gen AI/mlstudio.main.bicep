targetScope = 'subscription'
param resourceTags object

@allowed([
  'Default'
  'FeatureStore'
  'Hub'
  'Project'
])

param kind string 
@allowed([
  'Basic'
  'Enterprise'
])
param sku string

param location string

@allowed([
  'Basic' 
  'Free'
  'Premium' 
  'Standard'
])
param tier string

param resourceGroupName string

@allowed([
  'systemAssigned'
  'userAssigned'
])

param identityType string

param primaryUserAssignedIdentityResourceGroup string

param containerRegistryFirewallIPEnable string

param primaryUserAssignedIdentityName string

@allowed([
  'new'
  'existing'
])
param storageAccountOption string

param storageAccountSku string

param allowPulicAccessFromSelectedNetwork bool

@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string

param storageAccountResourceGroupName string
param enableDiagnosticSetting bool
param isHnsEnabled bool

@allowed([
  'new'
  'existing'
])
param keyVaultOption string

param enablePurgeProtection bool

param enableSoftDelete bool

param keyVaultResourceGroupName string

@allowed([
  'new'
  'existing'
])
param applicationInsightsOption string

param applicationInsightsResourceGroupName string

@allowed([
  'new'
  'existing'
])
param applicationInsightsLogWorkspaceOption string

@allowed([
  'new'
  'existing'
  'none'
])
param containerRegistryOption string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param containerRegistrySku string

param containerRegistryResourceGroupName string

param publicNetworkAccess string

param applicationInsightsLogWorkspaceResourceGroupName string

param domainName string

@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param pvSubnetName string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Private DNS Zone IDS')
param privateZoneDnsID array
@sys.description('Determines ML Studio Workspace Outbound Access Method.')
@allowed([
  'AllowInternetOutbound'
  'AllowOnlyApprovedOutbound'
  'Disabled'
])
param mlStudioManagedNetworkMode string

param environment string

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus: 'eu'
}

var groupIds = 'amlworkspace'


var resourceNames = {
  workspaceName : 'workk-08idabcd'
  appInsightsLogWorkspaceName : 'akk088cjdjabcd'
  storageAccountName : 'stre3gllfabcd'
  keyVaultName: 'key9jrfi4efgh'
  applicationInsightsName: 'all5errejhjefgh'
  containerRegistryName: 'tel34ti3efgh'
  privateEndpointName: 'snjsnij'
  
  privateEndpointNicNames: 'sfbsfsiuf'
  
}
var logWorkspaceId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${applicationInsightsLogWorkspaceResourceGroupName}/providers/microsoft.operationalinsights/workspaces/${resourceNames.appInsightsLogWorkspaceName}'
var storageAccountId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${storageAccountResourceGroupName}/providers/Microsoft.Storage/storageAccounts/${resourceNames.storageAccountName}'
var resouceID = existing_mlStudio.id

resource existing_mlStudio 'Microsoft.MachineLearningServices/workspaces@2022-12-01-preview' existing ={
  name:resourceNames.workspaceName
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

module new_storageAccount '../../../Modules/Storage Account/storage_account.mod.bicep' = if(storageAccountOption == 'new'){
  name:'storageAccountDeployment'
  scope: resourceGroup(resourceGroup_Creation.name)
  params:{
    resourceTags:resourceTags
    storageAccountName:resourceNames.storageAccountName
    storageAccountSku:storageAccountSku
    allowPulicAccessFromSelectedNetwork:allowPulicAccessFromSelectedNetwork
    isHnsEnabled:isHnsEnabled
    location:location
    networkAccessApproach:networkAccessApproach
  }
  dependsOn:[
    resourceGroup_Creation
  ]
}

module new_keyVault '../../../Modules/Key Vault/key_vault.mod.bicep' = if(keyVaultOption == 'new'){
  name:'newkeyVaultDeployment'
  scope: resourceGroup(resourceGroup_Creation.name)
  params:{
    enablePurgeProtection:enablePurgeProtection
    keyVaultName:resourceNames.keyVaultName
    networkAccessApproach:networkAccessApproach
    resourceTags:resourceTags
    allowPulicAccessFromSelectedNetwork:allowPulicAccessFromSelectedNetwork
    enableSoftDelete:enableSoftDelete
    location:location
  }
  dependsOn:[
    resourceGroup_Creation
  ]
}

module new_applicationInsight '../../../Modules/Application Insight/application_insight.mod.bicep' = if(applicationInsightsOption=='new'){
  name:'newApplicationInsightDeployment'
  scope: resourceGroup(resourceGroup_Creation.name)
  params:{
    name:resourceNames.applicationInsightsName
    resourceTags:resourceTags
    workspaceId:logWorkspaceId
    location:location
  }
  dependsOn:[
    resourceGroup_Creation
    new_appInsightLogWorkspace
  ]
}

module new_appInsightLogWorkspace '../../../Modules/Monitoring/log_analytic.mod.bicep' = if(applicationInsightsLogWorkspaceOption=='new'){
  name:'newappInsightLogWorkspaceDeployment'
  scope: resourceGroup(resourceGroup_Creation.name)
  params:{
    name:resourceNames.appInsightsLogWorkspaceName
    resourceTags:resourceTags
    location:location
  }
  dependsOn:[
    resourceGroup_Creation
  ]
}

module new_containerRegistry '../../../Modules/Container Registry/container_registry.mod.bicep' = if(containerRegistryOption=='new'){
  name:'newContainerRegistryDeployment'
  scope: resourceGroup(resourceGroup_Creation.name)
  params:{
    acrName:resourceNames.containerRegistryName
    location:location
    publicAccess:networkAccessApproach
    sku:containerRegistrySku
    firewallIPEnable:containerRegistryFirewallIPEnable
  }
  dependsOn:[
    resourceGroup_Creation
  ]
}


module mlstudio '../../../Modules/Machine Learning Studio/machine_learning.mod.bicep'= {
  scope: resourceGroup(resourceGroup_Creation.name)
  name: 'mlstudio'
  params: {
    applicationInsightsName: resourceNames.applicationInsightsName
    keyVaultName: resourceNames.keyVaultName
    location: location
    resourceGroupName: resourceGroupName
    storageAccountName: resourceNames.storageAccountName
    tagValues:resourceTags
    workspaceName: resourceNames.workspaceName
    containerRegistryName: resourceNames.containerRegistryName
    containerRegistryOption: containerRegistryOption
    sku: sku
    identityType: identityType
    containerRegistryResourceGroupName: containerRegistryResourceGroupName
    applicationInsightsResourceGroupName: applicationInsightsResourceGroupName
    keyVaultResourceGroupName: keyVaultResourceGroupName
    kind:kind
    primaryUserAssignedIdentityName: primaryUserAssignedIdentityName
    primaryUserAssignedIdentityResourceGroup: primaryUserAssignedIdentityResourceGroup
    publicNetworkAccess: publicNetworkAccess
    storageAccountResourceGroupName:storageAccountResourceGroupName
    tier: tier
    mlStudioManagedNetworkMode:mlStudioManagedNetworkMode
  }
  dependsOn:[
    resourceGroup_Creation
    new_storageAccount
    new_keyVault
    new_containerRegistry
    new_applicationInsight
  ]
}

module mlStudio_diagnostic '../../../Modules/Machine Learning Studio/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'mlstudio-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    mlStudioName: resourceNames.workspaceName
    workspaceId: logWorkspaceId
    storageAccountResourceId: storageAccountId
  }
  dependsOn: [
    mlstudio
  ]
}


module private_Endpoint '../../../Modules/Machine Learning Studio/mlstudio.privateendpoint.bicep' = if(networkAccessApproach=='Private'){
  scope: resourceGroup(resourceGroup_Creation.name)
  name:'mlStudioPrivateEndpointDeployment'
  params:{
    groupIDs:groupIds
    privateEndpointName:resourceNames.privateEndpointName
    privateEndpointNicNames:resourceNames.privateEndpointNicNames
    pvSubnetName:pvSubnetName
    resourceID: resouceID
    resourceTags:resourceTags
    vnetName:vnetName
    vnetResourceGroupName:vnetResourceGroupName
    location:location
  }
  dependsOn:[
    mlstudio
  ]
}

module private_Dns_Zone_Group '../../../Modules/Machine Learning Studio/mlstudio.dnszonegroup.mod.bicep' = if (networkAccessApproach == 'Private') {
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


