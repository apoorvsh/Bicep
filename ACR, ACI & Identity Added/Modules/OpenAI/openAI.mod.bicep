@description('AI Search Name')
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

resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: resourceTags
  sku: {
    name: sku
  }
  kind: 'OpenAI'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
    networkAcls: networkAccessApproach == 'Private' ? null : networkAcls
    customSubDomainName: name
    restore: cognitiveServiceRestore
    apiProperties: {
      statisticsEnabled: false
    }
  }
}
