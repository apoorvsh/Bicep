// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Login into the Jump Server VM, SHIR VM, Purview VM')
@secure()
param vmUserName string
@description('Login into the Jump Server VM, SHIR VM, Purview VM, SQL Database, Synapse Dedicated SQL Pool')
@secure()
param adminPassword string

// variables
@description('Key Vault Name')
var keyVaultName = toLower('akv${projectCode}${environment}secret01z2')
@description('Key Vault Sku')
var keyVaultSku = 'standard'
@description('Key Vault Family')
var keyVaultFamily = 'A'
@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId
var enabledForDeployment = false
var enabledForDiskEncryption = false
var enabledForTemplateDeployment = true
var enablePurgeProtection = true
var enableRbacAuthorization = false
var enableSoftDelete = true
var publicNetworkAccess = 'Disabled'

// creation of azure key vault
resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: union({
      Name: keyVaultName
    }, combineResourceTags)
  properties: {
    sku: {
      name: keyVaultSku
      family: keyVaultFamily
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    tenantId: tenantId
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
    accessPolicies: []
  }
}

// creating secret inside azure key vault
resource vmloginUserNamesecrets 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'vmUserName'
  parent: keyvault
  properties: {
    value: vmUserName
  }
}

// creating secret inside azure key vault
resource passwordsecrets 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'password'
  parent: keyvault
  properties: {
    value: adminPassword
  }
}

output keyvaultName string = keyvault.name
