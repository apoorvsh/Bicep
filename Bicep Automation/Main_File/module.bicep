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
@description('create Adls Gen2 storage account or Storage storage Account')
@allowed([
  'Adls_Gen2'
  'Storage'
])
param storageAccountType string
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
@description('Select your Organizational monitoring approach')
@allowed([
  'Centralized'
  'Decentralized'
])
param monitoringApproach string
@description('Log Analytics WorkSpace Pricing Tier')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param logAnalyticsPricingTier string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Centralized Workspace Resource ID')
param centralizedWorkspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
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
@description('Existing Azure Databricks Private DNS Zone')
param existingDatabricksPrivateDnsZoneId string
@description('Existing Azure Data Factory (dataFactory) Private DNS Zone')
param existingDataFactoryPrivateDnsZoneId string
@description('Existing Azure Data Factory (Portal) Private DNS Zone')
param existingPortalAdfPrivateDnsZoneId string
@description('Create Windows or Linux Virtual Machine as per the user choice')
@allowed([
  'Windows'
  'Linux'
])
param virtualMachineType string
@description('Location in which our Resources and Resources Groups will be deployed')
param location string = deployment().location
@description('Existing Network Resource Group Name')
param existingNetworkResourceGroupName string
@description('Existing Virtual Network Name')
param existingVnetName string
param vnetAddressSpace string
@description('Web Subent Address Prefix')
param webSubnetAddressPrefix string
@description('App Subent Address Prefix')
param appSubnetAddressPrefix string
@description('Data Subnet Address Prefix')
param dataSubnetAddressPrefix string
@description('Compute Subnet Address Prefix')
param computeSubnetAddressPrefix string
@description('Databricks Host Subnet Address Prefix')
param databricksHostSubnetAddressPrefix string
@description('Datbricks Container Subnet Name')
param databricksContainerSubentAddressPrefix string
@description('Next Hop of Ip Address')
param nextHopIpAddress string
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
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewAccountPrivateDnsZoneId string
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewPortalPrivateDnsZoneId string
@description('Existing Event Hub Private DNS Zone')
param existingEventHubPrivateDnsZoneId string
@description('Existing Azure Web Appp Private DNS Zone')
param existingWebAppPrivateDnsZoneId string
@description('App Service Plan Sku Type')
@allowed([
  'Basic'
  'Standard'
  'PremiumV2'
  'PremiumV3'
])
param appServiceSkuVersion string
@description('App Serive OS Version')
@allowed([
  'Linux'
  'Window'
])
param appServiceOsVersion string
@description('User Choice Logic App Type')
@allowed([
  'Consumption'
  'Standard'
])
param logicAppType string
@description('App Service Plan Sku Type for Standard Logic APP')
@allowed([
  'WS1'
  'WS2'
  'WS3'
])
param logicAppAppServiceSkuVersion string
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
@description('Existing IOT Hub Private DNS Zone Id')
param existingIotHubPrivateDnsZoneId string
@description('Existing Service Bus Private DNS Zone Id')
param existingServiceBusPrivateDnsZoneId string
@description('Cognitive Serivce Private DNS Zone Id')
param existingCognitiveServicePrivateDnsZoneId string
@allowed([
  'Training'
  'Prediction'
])
@description('Specify the value for Custom Vision Type')
param customVisionType string
@description('Cognitive Service is already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false"')
@allowed([
  true
  false ])
param cognitiveServiceRestore bool
@description('Existing Azure Automation Private Dns Zone id')
param existingAutomationPrivateDnsZoneId string
@description('Existing Machine Learning Private DNS Zone Id')
param existingMachineLearningPrivateDnsZoneId string
@description('Existing Notebook Private DNS Zone Id')
param existingNotebookPrivateDnsZoneId string
@description('Container Registry Sku "Private access (Recommended) is only available for Premium SKU."')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param continerRegistrySku string
@description('Existing Container Registry Private DNS Zone Id')
param existingContainerRegistryPrivateDnsZoneId string

// Resource group names all the resources will be deployed inside the resource group
// variables
@description('Network Resource Group Name')
var networkResourceGroupName = toLower('rg-${projectCode}-${environment}-network01')
@description('DataPlatform Resource Group Name')
var dataPlatformResourceGroupName = toLower('rg-${projectCode}-${environment}-dataPlatform01')
@description('Monitor Resource Group Name')
var monitorResourceGroupName = toLower('rg-${projectCode}-${environment}-monitor01')
@description('Databricks Resource Group Name')
var databricksResourceGroupName = toLower('rg-${projectCode}-${environment}-databricks01')
@description('Compute Resource Group Name')
var computeResourceGroupName = toLower('rg-${projectCode}-${environment}-compute01')
@description('Micrososft Purview Resource Group Name')
var purviewResourceGroupName = toLower('rg-${projectCode}-${environment}-mgmt01')

// creation of Monitor Resource group
resource monitorResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if (monitoringApproach == 'Decentralized') {
  name: monitorResourceGroupName
  location: location
  tags: union({
      Name: monitorResourceGroupName
    }, combineResourceTags)
}

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

// creation of databricks resource group
resource databricksResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: databricksResourceGroupName
  location: location
  tags: union({
      Name: databricksResourceGroupName
    }, combineResourceTags)
}

// creation of compute Resource group
resource computeResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: computeResourceGroupName
  location: location
  tags: union({
      Name: computeResourceGroupName
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

// creation of Log Analytics Workspace
module logAnalytics '../Log Analytics Workspace/logAnalyticsWorkspace.bicep' = if (monitoringApproach == 'Decentralized') {
  name: 'logAnalytics'
  scope: resourceGroup(monitorResourceGroup.name)
  //scope: monitorResourceGroup
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    pricingTier: logAnalyticsPricingTier
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
  }
}

// creation of Network Security Group 
module network '../Networking/networking.bicep' = {
  name: 'networking'
  dependsOn: [
    logAnalytics
  ]
  scope: resourceGroup(newOrExisting == 'New' ? newNetworkResourceGroup.name : existingNetworkResourceGroup.name)
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    networkAccessApproach: networkAccessApproach
    virtualMachineType: virtualMachineType
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    vnetAddressSpace: vnetAddressSpace
    existingVnetName: existingVnetName
    newOrExisting: newOrExisting
    appSubnetAddressPrefix: appSubnetAddressPrefix
    computeSubnetAddressPrefix: computeSubnetAddressPrefix
    databricksContainerSubentAddressPrefix: databricksContainerSubentAddressPrefix
    databricksHostSubnetAddressPrefix: databricksHostSubnetAddressPrefix
    dataSubnetAddressPrefix: dataSubnetAddressPrefix
    webSubnetAddressPrefix: webSubnetAddressPrefix
    nextHopIpAddress: nextHopIpAddress
  }
}

// creation of stroage account with it's private endpoints
module storageAccount '../Storage Account/storageAccount.bicep' = {
  name: 'storageAccount'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, logAnalytics
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
    storageAccountType: storageAccountType
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    existingBlobPrivateDnsZoneId: existingBlobPrivateDnsZoneId
    existingDfsPrivateDnsZoneId: existingDfsPrivateDnsZoneId
    existingFilePrivateDnsZoneId: existingFilePrivateDnsZoneId
    existingQueuePrivateDnsZoneId: existingQueuePrivateDnsZoneId
    existingTablePrivateDnsZoneId: existingTablePrivateDnsZoneId
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
  }
}

// creation of azure key vault with it's private endpoints
module keyVault '../Key Vault/keyVault.bicep' = {
  name: 'keyvault'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, logAnalytics
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
    enableDiagnosticSetting: enableDiagnosticSetting
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    retentionPolicyDays: retentionPolicyDays
    existingKeyVaultPrivateDnsZoneId: existingKeyVaultPrivateDnsZoneId
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
  }
}

// creation of Azure Datafactory
module adf '../Data Factory/dataFactory.bicep' = {
  name: 'adf'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, logAnalytics
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    subnetRef: network.outputs.dataSubnetId
    enableDiagnosticSetting: enableDiagnosticSetting
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    retentionPolicyDays: retentionPolicyDays
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    existingDataFactoryPrivateDnsZoneId: existingDataFactoryPrivateDnsZoneId
    existingPortalAdfPrivateDnsZoneId: existingPortalAdfPrivateDnsZoneId
  }
}

//  azure databricks workspace with it's private endpoints
module databricks '../Databricks/dataBricks.bicep' = {
  name: 'databricks'
  scope: databricksResourceGroup
  dependsOn: [
    network, logAnalytics
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    subnetRef: network.outputs.webSubnetId
    databricksContainerSubnetName: network.outputs.databricksContainerSubnetName
    databricksHostSubnetName: network.outputs.databricksHostSubnetName
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    existingDatabricksPrivateDnsZoneId: existingDatabricksPrivateDnsZoneId
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
  }
}

// creation of SHIR VM
module virtualMachine '../Virtual Machine/virtualMachine.bicep' = {
  name: 'virtualMachine'
  scope: computeResourceGroup
  dependsOn: [
    network, keyVault
  ]
  params: {
    projectCode: projectCode
    environment: environment
    vmUserName: keyVaultRef.getSecret('vmUserName')
    vmPassword: keyVaultRef.getSecret('vmPassword')
    location: location
    combineResourceTags: combineResourceTags
    subnetRef: network.outputs.computeSubnetId
    networkAccessApproach: networkAccessApproach
    virtualMachineType: virtualMachineType
  }
}

// creation of sql database with it's private endpoint
module sqlServer '../SQL Database/sqlDatabase.bicep' = {
  name: 'sqlServer'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, keyVault, logAnalytics
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
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
  }
}

// creation of Microsoft Purview with it's private endpoints
module azurePurview '../Microsoft Purview/purview.bicep' = {
  name: 'azurePurview'
  scope: purviewResourceGroup
  dependsOn: [
    network, logAnalytics, storageAccount
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    subnetRef: network.outputs.webSubnetId
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    blobPrivateDnsZoneId: networkArchitectureApproach == 'Federated' ? storageAccount.outputs.blobPrivateDnsZoneId : existingBlobPrivateDnsZoneId
    queuePrivateDnsZoneId: networkArchitectureApproach == 'Federated' ? storageAccount.outputs.queuePrivateDnsZoneId : existingQueuePrivateDnsZoneId
    existingEventHubPrivateDnsZoneId: existingEventHubPrivateDnsZoneId
    existingPviewAccountPrivateDnsZoneId: existingPviewAccountPrivateDnsZoneId
    existingPviewPortalPrivateDnsZoneId: existingPviewPortalPrivateDnsZoneId
  }
}

//creation of App Service Plan
module appService '../App Service/appService.bicep' = {
  name: 'appService'
  scope: dataPlatformResourceGroup
  dependsOn: [
    logAnalytics, network
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    appServiceOsVersion: appServiceOsVersion
    appServiceSkuVersion: appServiceSkuVersion
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    outboundSubnetId: network.outputs.appSubnetId
    subnetRef: network.outputs.webSubnetId
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    storageAccountName: storageAccount.outputs.storageAccountName
    existingWebAppPrivateDnsZoneId: existingWebAppPrivateDnsZoneId
  }
}

module customRole '../Custom Role/customRole.bicep' = {
  name: 'customRole'
  scope: resourceGroup(dataPlatformResourceGroup.name)
  params: {
    resourceGroupName: dataPlatformResourceGroup.name
  }
}

// creation of Azure Logic App Consumption
module logicApp '../Logic App/logicApp.bicep' = {
  name: 'logicApp'
  scope: resourceGroup(dataPlatformResourceGroup.name)
  dependsOn: [
    logAnalytics, network, storageAccount
  ]
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    outboundSubnetId: network.outputs.appSubnetId
    subnetRef: network.outputs.webSubnetId
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    logicAppAppServiceSkuVersion: logicAppAppServiceSkuVersion
    logicAppType: logicAppType
    existingWebAppPrivateDnsZoneId: existingWebAppPrivateDnsZoneId
    storageAccountName: storageAccount.outputs.storageAccountName
  }
}

// creation of azure synapse workspace with dedicated sql pool and it's private endpoints
module synapse '../Synapse/synapse.bicep' = {
  name: 'synapse'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, storageAccount, keyVault, logAnalytics
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
    computeSubnetRef: network.outputs.computeSubnetId
    adlsGen2SilverStorageAccountRef: storageAccount.outputs.storageAccountId
    dedicatedPoolSkuCapacity: dedicatedPoolSkuCapacity
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    existingSynapseDevPrivateDnsZoneId: existingSynapseDevPrivateDnsZoneId
    existingSynapseSqlPrivateDnsZoneId: existingSynapseSqlPrivateDnsZoneId
    storageAccountName: storageAccount.outputs.storageAccountName
    synapseFileSystemName: storageAccount.outputs.synapseContainerName
    sparkNodeSize: sparkNodeSize
    sparkNodeSizeFamily: sparkNodeSizeFamily
    sparkVersion: sparkVersion
    existingSynapseLinkHubPrivateDnsZoneId: existingSynapseLinkHubPrivateDnsZoneId
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
  }
}

module identity '../User Assign Managed Identity/UMI.bicep' = {
  name: 'identity'
  scope: dataPlatformResourceGroup
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
  }
}

// error in IOT HUB (error in this module)
module iotHub '../IOT Hub/IotHub.bicep' = {
  name: 'iotHub'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, logAnalytics, storageAccount, identity
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    retentionPolicyDays: retentionPolicyDays
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    enableDiagnosticSetting: enableDiagnosticSetting
    subnetRef: network.outputs.dataSubnetId
    storageAccountName: storageAccount.outputs.storageAccountName
    storageContainerName: storageAccount.outputs.iotHubContainerName
    existingIotHubPrivateDnsZoneId: existingIotHubPrivateDnsZoneId
    existingServiceBusPrivateDnsZoneId: existingServiceBusPrivateDnsZoneId
    identityId: identity.outputs.identityId
    principalId: identity.outputs.principalId
  }
}
module automation '../Automation Account/automationAccount.bicep' = {
  name: 'automationAccount'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, logAnalytics
  ]
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    retentionPolicyDays: retentionPolicyDays
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    enableDiagnosticSetting: enableDiagnosticSetting
    subnetRef: network.outputs.dataSubnetId
    existingAutomationPrivateDnsZoneId: existingAutomationPrivateDnsZoneId
  }
}

module cognitiveService '../Cognitive Service/cognitiverService.bicep' = {
  name: 'cognitiveService'
  scope: dataPlatformResourceGroup
  dependsOn: [
    network, logAnalytics
  ]
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    enableDiagnosticSetting: enableDiagnosticSetting
    networkAccessApproach: networkAccessApproach
    retentionPolicyDays: retentionPolicyDays
    networkArchitectureApproach: networkArchitectureApproach
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    subnetRef: network.outputs.dataSubnetId
    existingCognitiveServicePrivateDnsZoneId: existingCognitiveServicePrivateDnsZoneId
    customVisionType: customVisionType
    cognitiveServiceRestore: cognitiveServiceRestore
  }
}

module applicationInsight '../Machine Learning Workspace/applicationInsight.bicep' = {
  name: 'applicationInsight'
  scope: dataPlatformResourceGroup
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    retentionPolicyDays: retentionPolicyDays
    vnetId: newOrExisting == 'New' ? network.outputs.newVnetId : network.outputs.existingVnetId
    vnetName: newOrExisting == 'New' ? network.outputs.newVnetName : existingVnetName
    workspaceId: monitoringApproach == 'Decentralized' ? logAnalytics.outputs.deCentralizedWorkspaceId : centralizedWorkspaceId
    enableDiagnosticSetting: enableDiagnosticSetting
    subnetRef: network.outputs.dataSubnetId
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    keyVaultId: keyVault.outputs.keyVaultId
    storageAccountId: storageAccount.outputs.storageAccountId
    existingContainerRegistryPrivateDnsZoneId: existingContainerRegistryPrivateDnsZoneId
    existingMachineLearningPrivateDnsZoneId: existingMachineLearningPrivateDnsZoneId
    existingNotebookPrivateDnsZoneId: existingNotebookPrivateDnsZoneId
    continerRegistrySku: continerRegistrySku
  }
}
