targetScope = 'subscription'

//Global Parameter
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Creation of Resource Tags')
param combineResourceTags object
@description('Location in which our Resources will be deployed')
param location string
@description('Login Credentials')
@secure()
param vmUserName string
@description('Login Credentials')
@secure()
param adminPassword string
// existing vnet and network resource group deployed on azure

// Resource group names all the resources will be deployed inside the resource group
// variables
@description('Data Platform Resource Group Name')
var dataPlatformResourceGroupName = toLower('rg-${projectCode}-${environment}-dataPlatform06')

// existing resource group name (Network Resource Group) that is already deployed on azure 

// Networking resources like Network Security Group (NSG), User defined Routes, Subnets 

// creation of dataPlatform Resource group
resource dataPlatformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: dataPlatformResourceGroupName
  location: location
  tags: union({
      Name: dataPlatformResourceGroupName
    }, combineResourceTags)
}

// creation of  Bronze stroage account with it's private endpoints
module jumpServerVm '../Data Platform/jumpServerVm.bicep' = {
  name: 'jumpServerVm'
  scope: dataPlatformResourceGroup
  dependsOn: [
    keyVault
  ]
  params: {
    projectCode: projectCode
    environment: environment
    vmUserName: existingkv.getSecret('vmUserName')
    adminPassword: existingkv.getSecret('password')
    location: location
    combineResourceTags: combineResourceTags

  }
}

resource existingkv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVault.outputs.keyvaultName
  scope: dataPlatformResourceGroup
}

module keyVault '../Data Platform/keyVault.bicep' = {
  name: 'keyvault'
  scope: dataPlatformResourceGroup
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    adminPassword: adminPassword
    vmUserName: vmUserName
  }
}
