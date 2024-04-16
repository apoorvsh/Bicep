@description('Key Vault Name')
param keyVaultName string
@description('Adding Azure Data Factory to Access Policies of Azure Key Vault to fetch credentials when making Linked service in ADF')
param adfObjectId string = ''
@description('Perform all data plane operations on a key vault and all objects in it, including certificates, keys, and secrets. Cannot manage key vault resources or manage role assignments. Only works for key vaults that use the "Azure role-based access control" permission model.')
param kvAccessADGroupObjectId string = ''

// variables
@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
var permissions = [
  {
    objectId: adfObjectId
    tenantId: tenant().tenantId
    permissions: {
      secrets: [ 'get', 'list' ]
    }
  }
  {
    objectId: kvAccessADGroupObjectId
    tenantId: tenant().tenantId
    permissions: {
      secrets: [ 'all' ]
    }
  }
]

// Create access policies based on provided parameters
var accessPolicies = [for config in permissions: (!empty(adfObjectId) && !empty(kvAccessADGroupObjectId)) ? config : last(permissions)]

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// adding access policies to existing azure key vault
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: accessPolicies
  }
}
