param storageAccountName string
param storageAccountSku string = 'Standard_LRS'
param location string
param kind string
param accessTier string
param paccess array
param containername array
param count int



resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: kind
  properties: {
    accessTier: accessTier
  }
}

resource blobs 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for i in range(0,count): {
   name: '${storageAccountName}${storageAccountName}${containername[i]}'
   parent: blobs
   properties: {
    publicAccess: paccess[i]
   }
}]




