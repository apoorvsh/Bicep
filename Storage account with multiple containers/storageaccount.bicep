param storageName string 
param storageAccountTagName object
param kind string
param publicAccess string
param sku string
param containerName array

resource picstorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: resourceGroup().location
  tags: storageAccountTagName.tagA
  kind: kind
  sku: {
    name: sku
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [ for name in containerName: {
  name : '${picstorage.name}/default/${(name)}'
  properties: {
  publicAccess: publicAccess
  }
}]




