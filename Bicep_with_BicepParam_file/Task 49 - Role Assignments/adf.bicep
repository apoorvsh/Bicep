param values object 



resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: values.adfName
  location: values.location
  identity: {
    type: values.type
  }
  properties: {
    publicNetworkAccess: values.networkAccess
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: dataFactory
  name: guid(resourceGroup().id, values.principalId, values.roleDefinitionResourceId)
  properties: {
    roleDefinitionId: values.roleDefinitionResourceId
    principalId: values.principalId
    principalType: 'Group'
     
  }
}


output adfId string = dataFactory.id
