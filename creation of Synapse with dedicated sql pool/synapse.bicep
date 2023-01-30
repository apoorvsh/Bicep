param synapseName string
param synapseTagName object
@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param storageAccountUrl string
param fileSystemName string
param dedicatedSqlPoolName string
param sqlPoolTagName object
param sqlPoolCapacity int 
param sqlPoolName string
param sqlTier string

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: resourceGroup().location
  tags: synapseTagName.tagA
   identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    defaultDataLakeStorage: {
      accountUrl: storageAccountUrl
      filesystem: fileSystemName
    }
  }
}

resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name : dedicatedSqlPoolName
  location: resourceGroup().location
  tags: sqlPoolTagName.tagA
  parent: synapse
  sku: {
    capacity: sqlPoolCapacity
    name: sqlPoolName
    tier: sqlTier
  }
  properties: {
  }
}
