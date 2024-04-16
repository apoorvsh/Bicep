@description('Azure Data Factory Name')
param name string
@description('Create and manage data factories, as well as child resources within them.')
param adfAccessADGroupObjectId string

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: name
}

@description('Create and manage data factories, as well as child resources within them.')
var roleDefinitionId = '673868aa-7521-48a0-acc6-0f60742d39f5'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: adf
  name: guid(adf.id, adfAccessADGroupObjectId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: adfAccessADGroupObjectId
  }
}
