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
@description('Existing Blob Private DNS Zone of Storage Account')
param existingBlobPrivateDnsZoneId string
@description('Existing Queue Private DNS Zone of Storage Account')
param existingQueuePrivateDnsZoneId string
@description('Existing File Private DNS Zone of Storage Account')
param existingFilePrivateDnsZoneId string
@description('Existing Table Private DNS Zone of Storage Account')
param existingTablePrivateDnsZoneId string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool
@description('subnet address Prefix')
param appSubnetAddressPrefix string
@description('Existing Web App Private DNS Zone')
param existingWebAppPrivateDnsZoneId string
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
module storageAccount '../Logic App/storageAccount.bicep' = {
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
    existingFilePrivateDnsZoneId: existingFilePrivateDnsZoneId
    existingQueuePrivateDnsZoneId: existingQueuePrivateDnsZoneId
    existingTablePrivateDnsZoneId: existingTablePrivateDnsZoneId
    vnetAddressSpace: vnetAddressSpace
    subnetAddressPrefix: subnetAddressPrefix
    appSubnetAddressPrefix: appSubnetAddressPrefix
  }
}

module logicApp '../Logic App/consumptionLogicApp.bicep' = {
  name: 'logicApp'
  dependsOn: [
    storageAccount
  ]
  scope: dataPlatformResourceGroup
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    outboundSubnetId: storageAccount.outputs.appSubentId
    subnetRef: storageAccount.outputs.subnetId
    vnetId: storageAccount.outputs.vnetId
    vnetName: storageAccount.outputs.vnetName
    storageAccountName: storageAccount.outputs.storageAccountName
    existingWebAppPrivateDnsZoneId: existingWebAppPrivateDnsZoneId
    logicAppAppServiceSkuVersion: logicAppAppServiceSkuVersion
    logicAppType: logicAppType
  }
}
