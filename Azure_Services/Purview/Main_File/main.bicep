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
@description('Existing Queue Private DNS Zone of Storage Account')
param existingQueuePrivateDnsZoneId string
@description('Existing Blob Private DNS Zone of Storage Account')
param existingBlobPrivateDnsZoneId string
@description('Existing Event Hub Private DNS Zone')
param existingEventHubPrivateDnsZoneId string
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewAccountPrivateDnsZoneId string
@description('Existing  Microsoft Purview Private DNS Zone Id')
param existingPviewPortalPrivateDnsZoneId string

// variables
@description('Micrososft Purview Resource Group Name')
var purviewResourceGroupName = toLower('rg-${projectCode}-${environment}-mgmt01')

// creation of dataPlatform Resource group
resource purviewResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: purviewResourceGroupName
  location: location
  tags: union({
      Name: purviewResourceGroupName
    }, combineResourceTags)
}

module purview '../Purview/purview.bicep' = {
  name: 'purview'
  scope: purviewResourceGroup
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    subnetAddressPrefix: subnetAddressPrefix
    vnetAddressSpace: vnetAddressSpace
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    blobPrivateDnsZoneId: existingBlobPrivateDnsZoneId
    queuePrivateDnsZoneId: existingQueuePrivateDnsZoneId
    existingEventHubPrivateDnsZoneId: existingEventHubPrivateDnsZoneId
    existingPviewAccountPrivateDnsZoneId: existingPviewAccountPrivateDnsZoneId
    existingPviewPortalPrivateDnsZoneId: existingPviewPortalPrivateDnsZoneId
  }
}
