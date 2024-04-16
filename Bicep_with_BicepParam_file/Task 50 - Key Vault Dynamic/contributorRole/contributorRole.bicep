param values object


resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: values.keyVaultName
}



resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(resourceGroup().id, values.PrincipalId, values.contributorRoleDefinitionResourceId)
  properties: {
    roleDefinitionId: values.contributorRoleDefinitionResourceId
    principalId: values.PrincipalId
    principalType: 'User'
     
  }
}
