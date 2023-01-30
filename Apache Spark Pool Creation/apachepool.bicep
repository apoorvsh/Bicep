
param synapseName string
param synapseTagName object
param synapseLocation string = resourceGroup().location
@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param storageAccountUrl string
param fileSystemName string
param apacheSparkPoolName string
param apacheSparkPoolLocation string = resourceGroup().location
param apacheSparkPoolTagName object
param sparkNodeSize string
param sparkPoolNodeSizeFamily string
param sparkPoolDelayInMinutes int
param sparkPoolAutoPauseEnable bool
param sparkPoolAutoScaleEnable bool
param sparkPoolMaxNodeCount int
param sparkPoolMinNodeCount int
param saprkPoolDynamicExecutorAllocation bool
var sparkVersion = '3.2'

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: synapseLocation
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

resource apacheSparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: apacheSparkPoolName
  location: apacheSparkPoolLocation
  tags: apacheSparkPoolTagName.tagA
  parent: synapse
  properties: {
    sparkVersion: sparkVersion
    nodeSize: sparkNodeSize
    nodeSizeFamily: sparkPoolNodeSizeFamily
    autoPause: {
      delayInMinutes: sparkPoolDelayInMinutes
      enabled: sparkPoolAutoPauseEnable
    }
    autoScale: {
      enabled: sparkPoolAutoScaleEnable
      maxNodeCount: sparkPoolMaxNodeCount
      minNodeCount: sparkPoolMinNodeCount
    }
    dynamicExecutorAllocation: {
      enabled: saprkPoolDynamicExecutorAllocation
    }
  }
}




