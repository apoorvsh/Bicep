@description('Function APP Name')
param name string
@description('Manage websites, but not web plans. Does not allow you to assign roles in Azure RBAC.')
param funAppAccessADGroupObjectId string

resource fun_app 'Microsoft.Web/sites@2022-09-01' existing = {
  name: name
}

@description('Manage websites, but not web plans. Does not allow you to assign roles in Azure RBAC.')
var roleDefinitionId = 'de139f84-1756-47ae-9be6-808fbbe84772'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: fun_app
  name: guid(fun_app.id, funAppAccessADGroupObjectId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: funAppAccessADGroupObjectId
  }
}
