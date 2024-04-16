@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
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
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('outboundSubnetId for Vnet Integration inside Standard Logic App')
param outboundSubnetId string
@description('Data Subnet Id for Prviate Endpoint')
param subnetRef string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string
@description('Existing Key Vault Private DNS Zone')
param existingWebAppPrivateDnsZoneId string
@description('Existing Storage Account ')
param storageAccountName string

//creation of App Service Plan
module appServicePlan 'appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    workspaceId: workspaceId
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    appServiceOsVersion: appServiceOsVersion
    appServiceSkuVersion: appServiceSkuVersion
  }
}

module webApp 'webApp.bicep' = {
  name: 'webApp'
  dependsOn: [
    appServicePlan
  ]
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    vnetId: vnetId
    vnetName: vnetName
    subnetRef: subnetRef
    outboundSubnetId: outboundSubnetId
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    existingWebAppPrivateDnsZoneId: existingWebAppPrivateDnsZoneId
    workspaceId: workspaceId
    retentionPolicyDays: retentionPolicyDays
    enableDiagnosticSetting: enableDiagnosticSetting
  }
}

module functionApp 'functionApp.bicep' = {
  name: 'functionApp'
  dependsOn: [
    appServicePlan
  ]
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    storageAccountName: storageAccountName
    privateDnsZoneId: webApp.outputs.privateDnsZoneId
    subnetRef: subnetRef
    outboundSubnetId: outboundSubnetId
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    existingWebAppPrivateDnsZoneId: existingWebAppPrivateDnsZoneId
    workspaceId: workspaceId
    retentionPolicyDays: retentionPolicyDays
    enableDiagnosticSetting: enableDiagnosticSetting
  }
}
