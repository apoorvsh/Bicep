@description('Key Vault Name')
param storageName string
@description('Azure AD Group Object ID is required to manage keys, secrets, cerficate inside Key Vault')
param storageAccessADGroupObjectId string

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageName
}

@description('Perform all data plane operations on a key vault and all objects in it, including certificates, keys, and secrets. Cannot manage key vault resources or manage role assignments. Only works for key vaults that use the "Azure role-based access control" permission model.')
var roleDefinitionId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storage
  name: guid(storage.id, storageAccessADGroupObjectId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: storageAccessADGroupObjectId
  }
}
