targetScope = 'subscription'

//Global Parameter
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resource Tags')
param combineResourceTags object
@description('Location in which our Resources and Resources Groups will be deployed')
param location string = deployment().location
@description('Vnet Address Space')
param vnetAddressSpace string
@description('subnet address Prefix')
param subnetAddressPrefix string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
// SQL Active Directory admin for azure Synapse
@description('User e-mail Id required to make Azure Active Directory admin in Azure Synapse')
param synapseWSAdminUser string
@description('User object Id required to make Azure Active Directory admin in Azure Synapse')
param synapseWSAdminSID string
@description('User Name for login into SQL database, Dedicated SQL Pool')
@secure()
param sqlUserName string
@description('Password for login into SQL database, Dedicated SQL Pool ')
@secure()
param sqlPassword string
@description('Existing Blob Private DNS Zone of Storage Account')
param existingBlobPrivateDnsZoneId string
@description('Existing Dfs Private DNS Zone of Storage Account')
param existingDfsPrivateDnsZoneId string
@description('Existing Queue Private DNS Zone of Storage Account')
param existingQueuePrivateDnsZoneId string
@description('Existing File Private DNS Zone of Storage Account')
param existingFilePrivateDnsZoneId string
@description('Existing Table Private DNS Zone of Storage Account')
param existingTablePrivateDnsZoneId string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool
@description('Synaspe Dedicated SQL Poll Sku Type')
@allowed([
  'DW100c'
  'DW400c'
  'DW1000c'
])
param dedicatedPoolSkuCapacity string
@description('Optional. The Apache Spark version.')
@allowed([
  '3.3'
  '3.2'
  '3.1'
])
param sparkVersion string
@description('Optional. The kind of nodes that the Spark Pool provides.')
@allowed([
  'MemoryOptimized'
  'HardwareAccelerated'
])
param sparkNodeSizeFamily string
@description('Optional. The level of compute power that each node in the Big Data pool has.')
@allowed([
  'Small'
  'Medium'
  'Large'
  'XLarge'
  'XXLarge'
])
param sparkNodeSize string
@description('Existing Azure Synapse Dev Private DNS Zone')
param existingSynapseDevPrivateDnsZoneId string
@description('Existing Azure Synapse SQL On Demand Private DNS Zone')
param existingSynapseSqlPrivateDnsZoneId string
@description('Existing Azure Synapse Private Link Hub Private DNS Zone')
param existingSynapseLinkHubPrivateDnsZoneId string

// variables
@description('Data Platform Resource Group Name')
var dataPlatformResourceGroupName = toLower('rg-${projectCode}-${environment}-dp01')

// creation of dataPlatform Resource group
resource dataPlatformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: dataPlatformResourceGroupName
  location: location
  tags: union({
      Name: dataPlatformResourceGroupName
    }, combineResourceTags)
}

// creation of stroage account with it's private endpoints
module storageAccount '../Synaspe/storageAccount.bicep' = {
  name: 'storageAccount'
  scope: dataPlatformResourceGroup
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    existingBlobPrivateDnsZoneId: existingBlobPrivateDnsZoneId
    existingDfsPrivateDnsZoneId: existingDfsPrivateDnsZoneId
    existingFilePrivateDnsZoneId: existingFilePrivateDnsZoneId
    existingQueuePrivateDnsZoneId: existingQueuePrivateDnsZoneId
    existingTablePrivateDnsZoneId: existingTablePrivateDnsZoneId
    vnetAddressSpace: vnetAddressSpace
    subnetAddressPrefix: subnetAddressPrefix
  }
}

// creation of azure synapse workspace with dedicated sql pool and it's private endpoints
module synapse '../Synaspe/synapse.bicep' = {
  name: 'synapse'
  scope: dataPlatformResourceGroup
  dependsOn: [
    storageAccount
  ]
  params: {
    projectCode: projectCode
    environment: environment
    synapseWSAdminUser: synapseWSAdminUser
    synapseWSAdminSID: synapseWSAdminSID
    sqlUserName: sqlUserName
    adminPassword: sqlPassword
    location: location
    combineResourceTags: combineResourceTags
    adlsGen2SilverStorageAccountRef: storageAccount.outputs.storageAccountId
    dedicatedPoolSkuCapacity: dedicatedPoolSkuCapacity
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    vnetId: storageAccount.outputs.vnetId
    vnetName: storageAccount.outputs.vnetName
    subnetRef: storageAccount.outputs.subnetId
    existingSynapseDevPrivateDnsZoneId: existingSynapseDevPrivateDnsZoneId
    existingSynapseSqlPrivateDnsZoneId: existingSynapseSqlPrivateDnsZoneId
    storageAccountName: storageAccount.outputs.storageAccountName
    synapseFileSystemName: storageAccount.outputs.synapseContainerName
    sparkNodeSize: sparkNodeSize
    sparkNodeSizeFamily: sparkNodeSizeFamily
    sparkVersion: sparkVersion
    existingSynapseLinkHubPrivateDnsZoneId: existingSynapseLinkHubPrivateDnsZoneId
  }
}
