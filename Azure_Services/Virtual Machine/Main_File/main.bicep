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
@description('User Name for login into Virtual Machine')
@secure()
param vmUserName string
@description('Password for login into Virtual Machine')
@secure()
param vmPassword string
@description('Create Windows or Linux Virtual Machine as per the user choice')
@allowed([
  'Windows'
  'Linux'
])
param virtualMachineType string

// variables
@description('Data Platform Resource Group Name')
var computeResourceGroupName = toLower('rg-${projectCode}-${environment}-compute01')

// creation of Compute Resource group
resource computeResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: computeResourceGroupName
  location: location
  tags: union({
      Name: computeResourceGroupName
    }, combineResourceTags)
}

// creation of Virtual Machine
module virtualMachine '../Virtual Machine/virtualMachine.bicep' = {
  name: 'virtualMachine'
  scope: computeResourceGroup
  params: {
    projectCode: projectCode
    environment: environment
    location: location
    combineResourceTags: combineResourceTags
    networkAccessApproach: networkAccessApproach
    vnetAddressSpace: vnetAddressSpace
    subnetAddressPrefix: subnetAddressPrefix
    vmUserName: vmUserName
    vmPassword: vmPassword
    virtualMachineType: virtualMachineType
  }

}
