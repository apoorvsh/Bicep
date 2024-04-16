param vaultName string
param location string 

@description('The SKU of the vault to be created.')
@allowed([
  'standard'
  'premium'
])
param skuName string 

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: vaultName
  location: location
  properties: {
    accessPolicies:[]
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

//Reference : https://learn.microsoft.com/en-us/azure/key-vault/keys/quick-create-bicep?tabs=CLI
