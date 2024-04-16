param container array
param storageAccountName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' existing = {
  name: 'default'
  parent: storageAccount
}

// creation of container inside azure storage account
resource storage_containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for config in container: {
  name: config.name
  parent: blob
  properties: {
    publicAccess: config.blobPublicAccess
  }
}]
