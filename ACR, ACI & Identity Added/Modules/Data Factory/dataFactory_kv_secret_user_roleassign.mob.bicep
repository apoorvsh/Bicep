@description('Key Vault Name')
param keyVaultName string
@description('Azure Data Factory Pricipal ID to assign KV Secret user to ADF to fetch secrets during Linked Service form Key Vault')
param adfPrincipalID string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

@description('Perform all data plane operations on a key vault and all objects in it, including certificates, keys, and secrets. Cannot manage key vault resources or manage role assignments. Only works for key vaults that use the "Azure role-based access control" permission model.')
var roleDefinitionId = '4633458b-17de-408a-b874-0445c86b69e6'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, adfPrincipalID, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: adfPrincipalID
    principalType: 'ServicePrincipal'
  }
}
