param values object


resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: values.keyVaultName
}



resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, values.PrincipalId, values.adminRoleDefinitionResourceId)
  properties: {
    roleDefinitionId: values.adminRoleDefinitionResourceId
    principalId: values.PrincipalId
    principalType: 'User'
     
  }
}
