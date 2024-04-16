targetScope = 'subscription'

//Global Parameter
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resource Tags')
param combineResourceTags object
@allowed([
  'New'
  'Existing'
])
param newOrExisting string
@description('Network Access Approach Public or Private')
@allowed([
  'Public'
  'Private'
])
param networkAccessApproach string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool
@description('Select your Organizational networking architecture approach')
@allowed([
  'Federated'
  'Hub & Spoke'
])
param networkArchitectureApproach string
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
@description('User Name for login into Virtual Machine')
@secure()
param vmUserName string
@description('Password for login into Virtual Machine')
@secure()
param vmPassword string
@description('User Name for login into SQL database, Dedicated SQL Pool')
@secure()
param sqlUserName string
@description('Password for login into SQL database, Dedicated SQL Pool ')
@secure()
param sqlPassword string
@description('Existing Key Vault Private DNS Zone')
param existingKeyVaultPrivateDnsZoneId string
@description('Existing Azure Data Factory (dataFactory) Private DNS Zone')
param existingDataFactoryPrivateDnsZoneId string
@description('Existing Azure Data Factory (Portal) Private DNS Zone')
param existingPortalAdfPrivateDnsZoneId string
@description('Location in which our Resources and Resources Groups will be deployed')
param location string = deployment().location
@description('Existing Network Resource Group Name')
param existingNetworkResourceGroupName string
@description('Existing Virtual Network Name')
param existingVnetName string
param vnetAddressSpace string
@description('Data Subnet Address Prefix')
param dataSubnetAddressPrefix string
// SQL Active Directory admin for Azure SQL Server
@description('User e-mail Id required to make Azure Active Directory admin in Azure SQL Server')
param sqlAdminUser string
@description('User object Id required to make Azure Active Directory admin in Azure SQL Server')
param sqlAdminSID string
@description('SQL Database Performance Model')
@allowed([
  'Basic'
  'Standard'
  'Premium'
  'GeneralPurpose'
])
param sqlDatabasePerformanceModel string
@description('Redundancy for SQL Database')
@allowed([
  'Geo'
  'GeoZone'
  'Local'
  'Zone'
])
param requestedBackupStorageRedundancySqlServer string
@description('Existing SQL Server Private DNS Zone')
param existingSqlServerPrivateDnsZoneId string
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
// SQL Active Directory admin for azure Synapse
@description('User e-mail Id required to make Azure Active Directory admin in azure Synapse')
param synapseWSAdminUser string
@description('User object Id required to make Azure Active Directory admin in azure Synapse')
param synapseWSAdminSID string
@description('Existing Azure Synapse Dev Private DNS Zone')
param existingSynapseDevPrivateDnsZoneId string
@description('Existing Azure Synapse SQL On Demand Private DNS Zone')
param existingSynapseSqlPrivateDnsZoneId string
@description('Existing Azure Synapse Private Link Hub Private DNS Zone')
param existingSynapseLinkHubPrivateDnsZoneId string
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewAccountPrivateDnsZoneId string
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewPortalPrivateDnsZoneId string
@description('Existing Event Hub Private DNS Zone')
param existingEventHubPrivateDnsZoneId string

// Resource group names all the resources will be deployed inside the resource group
// variables
@description('Network Resource Group Name')
var networkResourceGroupName = toLower('rg-${projectCode}-${environment}-network01')
@description('DataPlatform Resource Group Name')
var dataPlatformResourceGroupName = toLower('rg-${projectCode}-${environment}-dataPlatform01')
@description('Micrososft Purview Resource Group Name')
var purviewResourceGroupName = toLower('rg-${projectCode}-${environment}-mgmt01')

// creation of dataPlatform Resource group
resource dataPlatformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: dataPlatformResourceGroupName
  location: location
  tags: union({
      Name: dataPlatformResourceGroupName
    }, combineResourceTags)
  dependsOn: [
    newNetworkResourceGroup, existingNetworkResourceGroup
  ]
}

// existing resource group name (Network Resource Group) that is already deployed on azure 
resource existingNetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (newOrExisting == 'Existing') {
  name: existingNetworkResourceGroupName
}

// creation of network Resource group
resource newNetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (newOrExisting == 'New') {
  name: networkResourceGroupName
  location: location
  tags: union({
      Name: networkResourceGroupName
    }, combineResourceTags)
}

// creation of Microsoft Purview Resource group
resource purviewResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: purviewResourceGroupName
  location: location
  tags: union({
      Name: purviewResourceGroupName
    }, combineResourceTags)
}

// referencing existing key vault secrets to login into Virtual machines, SQl database, Dedicated Sql Pool
resource keyVaultRef 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVault.outputs.keyVaultName
  scope: dataPlatformResourceGroup
}

// creation of Network Security Group 
module network '../Networking/networking.bicep' = {
  name: 'networking'
  scope: resourceGroup(newOrExisting == 'New' ? newNetworkResourceGroup.name : existingNetworkResourceGroup.name)
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    vnetAddressSpace: vnetAddressSpace
    existingVnetName: existingVnetName
    newOrExisting: newOrExisting
    dataSubnetAddressPrefix: dataSubnetAddressPrefix

  }
}

// creation of stroage account with it's private endpoints
module storageAccount '../Storage Account/storageAccount.bicep' = {
  name: 'storageAccount'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    subnetRef: network.outputs.dataSubnetId
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    existingBlobPrivateDnsZoneId: existingBlobPrivateDnsZoneId
    existingFilePrivateDnsZoneId: existingFilePrivateDnsZoneId
    existingQueuePrivateDnsZoneId: existingQueuePrivateDnsZoneId
    existingTablePrivateDnsZoneId: existingTablePrivateDnsZoneId
  }
}

// creation of stroage account with it's private endpoints
module adlsGen2 '../adlsGen2 Storage Account/adlsGen2.bicep' = {
  name: 'adlsGen2'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, storageAccount
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    subnetRef: network.outputs.dataSubnetId
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    existingBlobPrivateDnsZoneId: existingBlobPrivateDnsZoneId
    existingFilePrivateDnsZoneId: existingFilePrivateDnsZoneId
    existingQueuePrivateDnsZoneId: existingQueuePrivateDnsZoneId
    existingTablePrivateDnsZoneId: existingTablePrivateDnsZoneId
    existingDfsPrivateDnsZoneId: existingDfsPrivateDnsZoneId
    tablePrivateDnsZoneId: storageAccount.outputs.tablePrivateDnsZoneId
    filePrivateDnsZoneId: storageAccount.outputs.filePrivateDnsZoneId
    queuePrivateDnsZoneId: storageAccount.outputs.queuePrivateDnsZoneId
    blobPrivateDnsZoneId: storageAccount.outputs.blobPrivateDnsZoneId
  }
}

// creation of azure key vault with it's private endpoints
module keyVault '../Key Vault/keyVault.bicep' = {
  name: 'keyvault'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network
  ]
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    subnetRef: network.outputs.dataSubnetId
    vmUserName: vmUserName
    vmPassword: vmPassword
    sqlUserName: sqlUserName
    sqlPassword: sqlPassword
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    existingKeyVaultPrivateDnsZoneId: existingKeyVaultPrivateDnsZoneId
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
  }
}

// creation of Azure Datafactory
module adf '../Data Factory/dataFactory.bicep' = {
  name: 'adf'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    subnetRef: network.outputs.dataSubnetId
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    existingDataFactoryPrivateDnsZoneId: existingDataFactoryPrivateDnsZoneId
    existingPortalAdfPrivateDnsZoneId: existingPortalAdfPrivateDnsZoneId
  }
}

// creation of sql database with it's private endpoint
module sqlServer '../SQL Database/sqlDatabase.bicep' = {
  name: 'sqlServer'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, keyVault
  ]
  params: {
    projectCode: projectCode
    environment: environment
    sqlAdminUser: sqlAdminUser
    sqlAdminSID: sqlAdminSID
    sqlUserName: keyVaultRef.getSecret('sqlUserName')
    adminPassword: keyVaultRef.getSecret('sqlPassword')
    combineResourceTags: combineResourceTags
    location: location
    subnetRef: network.outputs.dataSubnetId
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    requestedBackupStorageRedundancySqlServer: requestedBackupStorageRedundancySqlServer
    sqlDatabasePerformanceModel: sqlDatabasePerformanceModel
    existingSqlServerPrivateDnsZoneId: existingSqlServerPrivateDnsZoneId
  }
}

// creation of azure synapse workspace with dedicated sql pool and it's private endpoints
module synapse '../Synapse/synapse.bicep' = {
  name: 'synapse'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, storageAccount, keyVault
  ]
  params: {
    projectCode: projectCode
    environment: environment
    synapseWSAdminUser: synapseWSAdminUser
    synapseWSAdminSID: synapseWSAdminSID
    sqlUserName: keyVaultRef.getSecret('sqlUserName')
    adminPassword: keyVaultRef.getSecret('sqlPassword')
    location: location
    combineResourceTags: combineResourceTags
    dataSubnetRef: network.outputs.dataSubnetId
    computeSubnetRef: network.outputs.dataSubnetId
    adlsGen2SilverStorageAccountRef: storageAccount.outputs.storageAccountId
    dedicatedPoolSkuCapacity: dedicatedPoolSkuCapacity
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    existingSynapseDevPrivateDnsZoneId: existingSynapseDevPrivateDnsZoneId
    existingSynapseSqlPrivateDnsZoneId: existingSynapseSqlPrivateDnsZoneId
    storageAccountName: adlsGen2.outputs.storageAccountName
    synapseFileSystemName: adlsGen2.outputs.synapseContainerName
    sparkNodeSize: sparkNodeSize
    sparkNodeSizeFamily: sparkNodeSizeFamily
    sparkVersion: sparkVersion
    existingSynapseLinkHubPrivateDnsZoneId: existingSynapseLinkHubPrivateDnsZoneId
  }
}

// creation of Microsoft Purview with it's private endpoints
module azurePurview '../Microsoft Purview/purview.bicep' = {
  name: 'azurePurview'
  scope: purviewResourceGroup
  dependsOn: [
    network, storageAccount
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    subnetRef: network.outputs.dataSubnetId
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    blobPrivateDnsZoneId: networkArchitectureApproach == 'Federated' ? storageAccount.outputs.blobPrivateDnsZoneId : existingBlobPrivateDnsZoneId
    queuePrivateDnsZoneId: networkArchitectureApproach == 'Federated' ? storageAccount.outputs.queuePrivateDnsZoneId : existingQueuePrivateDnsZoneId
    existingEventHubPrivateDnsZoneId: existingEventHubPrivateDnsZoneId
    existingPviewAccountPrivateDnsZoneId: existingPviewAccountPrivateDnsZoneId
    existingPviewPortalPrivateDnsZoneId: existingPviewPortalPrivateDnsZoneId
  }
}
