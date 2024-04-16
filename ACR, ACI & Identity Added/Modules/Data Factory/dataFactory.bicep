@description('Resources Tags')
param resourceTags object
@description('Resource Location')
param location string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Azure Data Factory Name')
param adfName string
@description('Self Hosted Integration Name')
param shirName string = ''

@description('Azure Data Facotory Network access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'

// creation of azure data factory 
resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: adfName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
  }
}

// creation of Self Hosted Integration Runtime inside Azure Data Factory
resource adfShir 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if (shirName != 'null') {
  name: shirName
  parent: datafactory
  properties: {
    description: 'Self Hosted Integration Runtime'
    type: 'SelfHosted'
    typeProperties: {
      /* linkedInfo: {
        authorizationType: 'string'
        // For remaining properties, see LinkedIntegrationRuntimeType objects
      }*/
    }
  }
}

resource dataFactory_managedVNet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  name: 'default'
  parent: datafactory
  properties: {}
}

// output the object ID of azure data factory will use this in to add access policy in existing key vault
output adfIdentityPrincipalId string = datafactory.identity.principalId
output dataFactoryId string = datafactory.id
