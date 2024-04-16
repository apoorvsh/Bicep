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


output adlsId string = storageAccount.id
