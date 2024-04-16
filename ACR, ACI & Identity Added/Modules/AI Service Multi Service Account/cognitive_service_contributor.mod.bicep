@description('AI Multi Service Account Name')
param name string
@description('Lets you create, read, update, delete and manage keys of Cognitive Services.')
param aiCognitiveServiceAccessADGroupObjectId string

resource ai_service 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' existing = {
  name: name
}

@description('Lets you create, read, update, delete and manage keys of Cognitive Services.')
var roleDefinitionId = '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: ai_service
  name: guid(ai_service.id, aiCognitiveServiceAccessADGroupObjectId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: aiCognitiveServiceAccessADGroupObjectId
  }
}
