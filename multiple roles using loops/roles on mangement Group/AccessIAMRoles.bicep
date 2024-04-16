targetScope = 'managementGroup'

param contributor_RoleAssignment array 

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [ for config in contributor_RoleAssignment:  {
  //name: guid(policyAssignment.id, resourceGroup().id, roleDefinitionId)
  //name: guid(uniqueString(config.pricipalId))\
  name : guid(uniqueString('${config.pricipalId}${config.roleDefinationId}${managementGroup().id}'))
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', config.roleDefinationId)
    principalId: config.pricipalId
    //principalType: 'ServicePrincipal'
  }
}]
