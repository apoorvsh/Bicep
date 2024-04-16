@description('AI Service Multi Service Account Name')
param name string
@description('Resource Tags')
param resourceTags object
@description('Resource Location')
param location string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Cognitive Service is already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false"')
@allowed([
  true
  false ])
param cognitiveServiceRestore bool = false

var sku = 'S0'
var networkAcls = {
  bypass: 'AzureServices'
  virtualNetworkRules: []
  ipRules: []
  defaultAction: 'Allow'
}

resource aiService 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: name
  location: location
  tags: resourceTags
  sku: {
    name: sku
  }
  kind: 'CognitiveServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
    networkAcls: networkAccessApproach == 'Private' ? null : networkAcls
    customSubDomainName: name
    restore: cognitiveServiceRestore
    apiProperties: {}
  }
}
