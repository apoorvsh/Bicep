@description('Open AI Name')
param name string
@description('Full access including the ability to fine-tune, deploy and generate text')
param openAiAccessADGroupObjectId string

resource openAI 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: name
}

@description('Full access including the ability to fine-tune, deploy and generate text')
var roleDefinitionId = 'a001fd3d-188f-4b5d-821b-7da978bf7442'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: openAI
  name: guid(openAI.id, openAiAccessADGroupObjectId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: openAiAccessADGroupObjectId
  }
}
