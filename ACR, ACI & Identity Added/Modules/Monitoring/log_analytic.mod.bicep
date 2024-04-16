@description('Log Analytics Name')
param name string
@description('Resource Tags')
param resourceTags object
@description('Resource Location')
param location string

var sku = 'PerGB2018' //'CapacityReservation''Free''LACluster''PerGB2018''PerNode''Premium''Standalone''Standard' (required)
var publicNetworkAccessForIngestion = 'Enabled'
var publicNetworkAccessForQuery = 'Enabled'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: resourceTags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 90
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
