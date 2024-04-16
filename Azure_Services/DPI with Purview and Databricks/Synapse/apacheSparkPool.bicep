@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Required. Name of the Synapse Workspace.')
@minLength(5)
@maxLength(50)
param synapseWorkspaceName string
@description('Optional. The Apache Spark version.')
@allowed([
  '3.3'
  '3.2'
  '3.1'
])
param sparkVersion string = '3.3'
@description('Optional. The kind of nodes that the Spark Pool provides.')
@allowed([
  'MemoryOptimized'
  'HardwareAccelerated'
])
param sparkNodeSizeFamily string = 'MemoryOptimized'
@description('Optional. The level of compute power that each node in the Big Data pool has.')
@allowed([
  'Small'
  'Medium'
  'Large'
  'XLarge'
  'XXLarge'
])
param sparkNodeSize string = 'Medium'

@description('Azure Synapse Analytics WorkSpace Name')
var sparkPoolName = toLower('syn${projectCode}${environment}sp01')
@description('Optional. Enable Autoscale feature.')
var sparkAutoScaleEnabled = true
@description('Optional. Maximum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-scale is enabled.')
//@maxValue(200)
//@minValue(3)
var sparkAutoScaleMaxNodeCount = 6
@description('Optional. Minimum number of nodes to be allocated in the specified Spark pool. This parameter must be specified when Auto-Scale is enabled.')
//@maxValue(199)
//@minValue(3)
var sparkAutoScaleMinNodeCount = 3
@description('Optional. Whether compute isolation is required or not. (Feature not available in all regions)')
/*@allowed([
  false
  true
])*/
var sparkIsolatedComputeEnabled = false
@description('Number of nodes to be allocated in the Spark pool (If Autoscale is not enabled)')
var sparkNodeCount = 0
@description('Optional. Whether auto-pausing is enabled for the Big Data pool.')
var sparkAutoPauseEnabled = true
@description('Optional. Number of minutes of idle time before the Big Data pool is automatically paused.')
var sparkAutoPauseDelayInMinutes = 7
@description('Optional. Indicates whether Dynamic Executor Allocation is enabled or not')
var sparkDynamicExecutorEnabled = true
@description('Optional. The minimum number of executors alloted')
//@minValue(1)
//@maxValue(198)
var sparkMinExecutorCount = 1
@description('Optional. The Maximum number of executors alloted')
//@minValue(2)
//@maxValue(199)
var sparkMaxExecutorCount = 3
@description('Optional. The allocated Cache Size (in percentage)')
//@minValue(0)
//@maxValue(100)
var sparkCacheSize = 25
@description('Optional. The filename of the spark config properties file.')
var sparkConfigPropertiesFileName = ''
@description('Optional. The spark config properties.')
var sparkConfigPropertiesContent = ''
@description('Optional. Whether session level packages enabled.	')
var sessionLevelPackagesEnabled = false

// Get the existing Synapse Workspace (Used for Output purposes mainly)
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkspaceName
}

// Create Spark Pool Resource
resource sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  parent: synapseWorkspace
  name: sparkPoolName
  location: location
  tags: union({
      Name: sparkPoolName
    }, combineResourceTags)
  properties: {
    nodeCount: sparkNodeCount
    nodeSizeFamily: sparkNodeSizeFamily
    nodeSize: sparkNodeSize
    autoScale: {
      enabled: sparkAutoScaleEnabled
      minNodeCount: sparkAutoScaleMinNodeCount
      maxNodeCount: sparkAutoScaleMaxNodeCount
    }
    autoPause: {
      enabled: sparkAutoPauseEnabled
      delayInMinutes: sparkAutoPauseDelayInMinutes
    }
    sparkVersion: sparkVersion
    sparkConfigProperties: {
      filename: sparkConfigPropertiesFileName
      content: sparkConfigPropertiesContent
    }
    isComputeIsolationEnabled: sparkIsolatedComputeEnabled
    sessionLevelPackagesEnabled: sessionLevelPackagesEnabled
    dynamicExecutorAllocation: {
      enabled: sparkDynamicExecutorEnabled
      minExecutors: sparkMinExecutorCount
      maxExecutors: sparkMaxExecutorCount
    }

    // To investigate the cacheSize related warning - 'Warning: BCP073 The Property CacheSize is ReadOnly'
    cacheSize: sparkCacheSize
  }
}

output sparkPoolName string = sparkPool.name
output sparkPoolResourceId string = sparkPool.id
output synapseWorkspaceName string = synapseWorkspace.name
output SynapseWorkSpaceResourceId string = synapseWorkspace.id
output developmentEndpoint string = synapseWorkspace.properties.connectivityEndpoints.dev
