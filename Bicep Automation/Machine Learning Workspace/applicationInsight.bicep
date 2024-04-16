// Creates an Application Insights instance as dependency for Azure ML
// Global parameters
@description('Define the project name or prefix for all objects.')
@minLength(1)
@maxLength(11)
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Resource ID of the subnet resource')
param subnetRef string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Existing Machine Learning Private DNS Zone Id')
param existingMachineLearningPrivateDnsZoneId string
@description('Existing Notebook Private DNS Zone Id')
param existingNotebookPrivateDnsZoneId string
@description('Virtual Network Name')
param vnetName string
@description('Virtual Netowork Id')
param vnetId string
@description('Resource ID of the key vault resource')
param keyVaultId string
@description('Resource ID of the storage account resource')
param storageAccountId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Container Registry Sku "Private access (Recommended) is only available for Premium SKU."')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param continerRegistrySku string
@description('Existing Container Registry Private DNS Zone Id')
param existingContainerRegistryPrivateDnsZoneId string

@description('Application Insights resource name')
var applicationInsightsName = toLower('ml-${projectCode}-${environment}-insight01')

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: union({
      Name: applicationInsightsName
    }, combineResourceTags)
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
    Flow_Type: 'Bluefield'
  }
}

module containerRegistry 'containerRegistry.bicep' = {
  name: 'contianerRegistry'
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    workspaceId: workspaceId
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    subnetRef: subnetRef
    vnetId: vnetId
    vnetName: vnetName
    continerRegistrySku: continerRegistrySku
    existingContainerRegistryPrivateDnsZoneId: existingContainerRegistryPrivateDnsZoneId
  }
}

module machineLearning 'machineLearning.bicep' = {
  name: 'machineLearning'
  dependsOn: [
    containerRegistry
  ]
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    subnetRef: subnetRef
    vnetId: vnetId
    vnetName: vnetName
    existingMachineLearningPrivateDnsZoneId: existingMachineLearningPrivateDnsZoneId
    existingNotebookPrivateDnsZoneId: existingNotebookPrivateDnsZoneId
    applicationInsightsId: applicationInsights.id
    keyVaultId: keyVaultId
    storageAccountId: storageAccountId
    containerRegistryId: containerRegistry.outputs.containerRegistryId
    workspaceId: workspaceId
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
  }
}
