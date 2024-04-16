@description('AI Search Name')
param aiSearchName string
@description('Resource Tags')
param resourceTags object
@description('Resource Location')
param location string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string

var sku = 'standard'
var replicaCount = 1
var partitionCount = 1
var hostingMode = 'default' // or highDensity
@description('Azure Data Facotory Network access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'disabled' : 'enabled'
var networkAcls = {
  bypass: 'AzureServices'
  virtualNetworkRules: []
  ipRules: []
  defaultAction: 'Allow'
}

resource aiSearch 'Microsoft.Search/searchServices@2023-11-01' = {
  name: aiSearchName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: sku
  }
  properties: {
    replicaCount: replicaCount
    partitionCount: partitionCount
    hostingMode: hostingMode
    publicNetworkAccess: publicNetworkAccess
    networkRuleSet: networkAccessApproach == 'Private' ? null : networkAcls
  }
}

output aiSearchId string = aiSearch.id
