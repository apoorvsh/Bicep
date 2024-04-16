@description('APIM Name')
param name string
@description('Can manage service and the APIs')
param apimAccessADGroupObjectId string

resource apim 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: name
}

@description('Can manage service and the APIs')
var roleDefinitionId = '312a565d-c81f-4fd8-895a-4e21e48d571c'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: apim
  name: guid(apim.id, apimAccessADGroupObjectId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: apimAccessADGroupObjectId
  }
}
