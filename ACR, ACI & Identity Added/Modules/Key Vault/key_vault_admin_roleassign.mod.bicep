@description('Key Vault Name')
param keyVaultName string
@description('Azure AD Group Object ID is required to manage keys, secrets, cerficate inside Key Vault')
param kvAccessADGroupObjectId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

@description('Perform all data plane operations on a key vault and all objects in it, including certificates, keys, and secrets. Cannot manage key vault resources or manage role assignments. Only works for key vaults that use the "Azure role-based access control" permission model.')
var roleDefinitionId = '00482a5a-887f-4fb3-b363-3b7fe8e74483'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, kvAccessADGroupObjectId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: kvAccessADGroupObjectId
  }
}
