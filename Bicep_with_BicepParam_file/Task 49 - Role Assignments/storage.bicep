param values object 








resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: values.storageName
  location: values.location
  sku: {
    name: values.storageAccountSku
  }
  kind: values.kind
  properties: {
    isHnsEnabled: true
    accessTier: values.accessTier
    networkAcls: {
      defaultAction: 'Deny'
       bypass: 'AzureServices'

    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(storageAccount.id, values.principalId, values.roleDefinitionResourceId)
  properties: {
    roleDefinitionId: values.storageRoleDefinitionResourceId
    principalId: values.storagePrincipalID
    principalType: 'Group'
  }
}


output adlsId string = storageAccount.id
