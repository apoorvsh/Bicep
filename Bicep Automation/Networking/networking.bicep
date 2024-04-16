// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Create Windows or Linux Virtual Machine as per the user choice')
@allowed([
  'Windows'
  'Linux'
])
param virtualMachineType string
@description('Next Hop of Ip Address')
param nextHopIpAddress string
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
@allowed([
  'New'
  'Existing'
])
param newOrExisting string

// creation of Network Security Group 
module nsg 'nsgs.bicep' = {
  name: 'nsg'
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    networkAccessApproach: networkAccessApproach
    virtualMachineType: virtualMachineType
    workspaceId: workspaceId
  }
}

// creation of User Defined Routes
module routes 'routeTables.bicep' = if (networkAccessApproach == 'Private') {
  name: 'routes'
  dependsOn: [
    nsg
  ]
  params: {
    nextHopIpAddress: nextHopIpAddress
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
  }
}

// creation of Virtual Network and Subnets
module vnetSubnet 'vnetSubnet.bicep' = {
  name: 'vnetSubnet'
  dependsOn: [
    nsg, routes
  ]
  params: {
    combineResourceTags: combineResourceTags
    projectCode: projectCode
    location: location
    newOrExisting: newOrExisting
    vnetAddressSpace: vnetAddressSpace
    environment: environment
    existingVnetName: existingVnetName
    computeSubnetAddressPrefix: computeSubnetAddressPrefix
    dataSubnetAddressPrefix: dataSubnetAddressPrefix
    appSubnetAddressPrefix: appSubnetAddressPrefix
    databricksContainerSubentAddressPrefix: databricksContainerSubentAddressPrefix
    databricksHostSubnetAddressPrefix: databricksHostSubnetAddressPrefix
    webSubnetAddressPrefix: webSubnetAddressPrefix
    computeSubnetRouteRef: networkAccessApproach == 'Private' ? routes.outputs.computeSubnetRouteId : networkAccessApproach
    containerSubnetRouteRef: networkAccessApproach == 'Private' ? routes.outputs.containerSubnetRouteId : networkAccessApproach
    hostSubnetRouteRef: networkAccessApproach == 'Private' ? routes.outputs.hostSubnetRouteId : networkAccessApproach
    appSubnetRouteRef: networkAccessApproach == 'Private' ? routes.outputs.appSubnetRouteId : networkAccessApproach
    computeNsgRef: nsg.outputs.computeNsgId
    webNsgRef: nsg.outputs.webNsgId
    dataNsgRef: nsg.outputs.dataNsgId
    databricksNsgRef: nsg.outputs.databricksNsgId
    appNsgRef: nsg.outputs.appNsgId
    enableDiagnosticSetting: enableDiagnosticSetting
    retentionPolicyDays: retentionPolicyDays
    workspaceId: workspaceId
  }
}

output existingVnetId string = vnetSubnet.outputs.existingVnetId
output newVnetId string = vnetSubnet.outputs.newVnetId
output webSubnetId string = vnetSubnet.outputs.webSubnetId
output dataSubnetId string = vnetSubnet.outputs.dataSubnetId
output computeSubnetId string = vnetSubnet.outputs.computeSubnetId
output databricksHostSubnetId string = vnetSubnet.outputs.databricksHostSubnetId
output databricksContainerSubnetId string = vnetSubnet.outputs.databricksContainerSubnetId
output appSubnetId string = vnetSubnet.outputs.appSubnetId
output databricksHostSubnetName string = vnetSubnet.outputs.databricksHostSubnetName
output databricksContainerSubnetName string = vnetSubnet.outputs.databricksContainerSubnetName
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
