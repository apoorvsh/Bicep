// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Existing Virtual Network Name')
param existingVnetName string
param vnetAddressSpace string
@description('Data Subnet Address Prefix')
param dataSubnetAddressPrefix string
@allowed([
  'New'
  'Existing'
])
param newOrExisting string

// creation of Virtual Network and Subnets
module vnetSubnet 'vnetSubnet.bicep' = {
  name: 'vnetSubnet'
  params: {
    combineResourceTags: combineResourceTags
    projectCode: projectCode
    location: location
    newOrExisting: newOrExisting
    vnetAddressSpace: vnetAddressSpace
    environment: environment
    existingVnetName: existingVnetName

    dataSubnetAddressPrefix: dataSubnetAddressPrefix
  }
}

output existingVnetId string = vnetSubnet.outputs.existingVnetId
output newVnetId string = vnetSubnet.outputs.newVnetId
output dataSubnetId string = vnetSubnet.outputs.dataSubnetId
output newVnetName string = vnetSubnet.outputs.newVnetName

/*
// no need of this
// output of network security groups used in subnet.bicep
output computeNsgId string = networkSecurityGroup[0].id
output webNsgId string = networkSecurityGroup[1].id
output dataNsgId string = networkSecurityGroup[2].id
output databricksNsgId string = networkSecurityGroup[3].id
output appNsgId string = networkSecurityGroup[4].id
*/
