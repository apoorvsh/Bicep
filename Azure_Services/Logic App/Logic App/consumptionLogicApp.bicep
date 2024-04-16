// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('User Choice Logic App Type')
@allowed([
  'Consumption'
  'Standard'
])
param logicAppType string
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
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('App Service Plan Sku Type for Standard Logic APP')
@allowed([
  'WS1'
  'WS2'
  'WS3'
])
param logicAppAppServiceSkuVersion string
@description('Existing Storage Account ')
param storageAccountName string

// variables
@description('The name of the logic app to create.')
var logicAppName = toLower('la-${projectCode}-${environment}-mailalert01')
@description('Logic App workflow schema')
var workflowSchema = 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'

// creation of consumption logic app
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = if (logicAppType == 'Consumption') {
  name: logicAppName
  location: location
  tags: union({
      Name: logicAppName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    definition: {
      '$schema': workflowSchema
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {}
      actions: {}
      outputs: {}
    }
  }
}

module standardLogicApp 'standardLogicApp.bicep' = if (logicAppType == 'Standard') {
  name: 'standardLogicApp'
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    subnetRef: subnetRef
    vnetId: vnetId
    vnetName: vnetName
    outboundSubnetId: outboundSubnetId
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    existingWebAppPrivateDnsZoneId: existingWebAppPrivateDnsZoneId
    logicAppAppServiceSkuVersion: logicAppAppServiceSkuVersion
    storageAccountName: storageAccountName
  }
}

output webAppPrivateDnsZoneId string = logicAppType == 'Standard' ? standardLogicApp.outputs.webAppPrivateDnsZoneId : existingWebAppPrivateDnsZoneId
