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
@description('Existing Azure Automation Private Dns Zone id')
param existingAutomationPrivateDnsZoneId string

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

module automation '../Automation Account/automationAccount.bicep' = {
  name: 'automationAccount'
  scope: dataPlatformResourceGroup
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    vnetAddressSpace: vnetAddressSpace
    subnetAddressPrefix: subnetAddressPrefix
    existingAutomationPrivateDnsZoneId: existingAutomationPrivateDnsZoneId
  }
}
