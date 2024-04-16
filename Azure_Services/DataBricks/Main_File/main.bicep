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
@description('Databricks Host Subnet Address Prefix')
param databricksHostSubnetAddressPrefix string
@description('Datbricks Container Subnet Name')
param databricksContainerSubentAddressPrefix string
@description('Existing Azure Databricks Private DNS Zone')
param existingDatabricksPrivateDnsZoneId string

// variables
@description('DataPlatform Resource Group Name')
var dataPlatformResourceGroupName = toLower('rg-${projectCode}-${environment}-dataPlatform01')

// creation of dataPlatform Resource group
resource dataPlatformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: dataPlatformResourceGroupName
  location: location
  tags: union({
      Name: dataPlatformResourceGroupName
    }, combineResourceTags)
}

module databricks '../Databricks/databricks.bicep' = {
  name: 'databricks'
  scope: dataPlatformResourceGroup
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    subnetAddressPrefix: subnetAddressPrefix
    vnetAddressSpace: vnetAddressSpace
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    databricksContainerSubnetAddressSpace: databricksContainerSubentAddressPrefix
    databricksHostSubnetAddressSpace: databricksHostSubnetAddressPrefix
    existingDatabricksPrivateDnsZoneId: existingDatabricksPrivateDnsZoneId
  }
}
