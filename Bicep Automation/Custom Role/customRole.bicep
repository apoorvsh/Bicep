@description('creating new custom role with limited rights')
param resourceGroupName string

var actions = [
  'Microsoft.ServiceBus/namespaces/queues/write'
  'Microsoft.ServiceBus/namespaces/queues/read'
  'Microsoft.ServiceBus/namespaces/queues/Delete'
  'Microsoft.Storage/storageAccounts/blobServices/read'
  'Microsoft.Storage/storageAccounts/blobServices/containers/delete'
  'Microsoft.Storage/storageAccounts/blobServices/containers/read'
  'Microsoft.Storage/storageAccounts/blobServices/containers/lease/action'
  'Microsoft.Storage/storageAccounts/blobServices/write'
  'Microsoft.Storage/storageAccounts/blobServices/containers/write'
  'Microsoft.Resources/deployments/*'
  'Microsoft.Resources/deploymentScripts/*'
  'Microsoft.Storage/storageAccounts/fileServices/shares/delete'
  'Microsoft.Storage/storageAccounts/fileServices/shares/read'
  'Microsoft.Storage/storageAccounts/fileServices/shares/write'
  'Microsoft.Storage/storageAccounts/fileServices/write'
]
var notActions = []
var dataActions = [
  'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'
  'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete'
  'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write'
  'Microsoft.ServiceBus/namespaces/messages/send/action'
  'Microsoft.ServiceBus/namespaces/messages/receive/action'
]
var notDataActions = []
var roleDescription = 'Custom Role'

var roleDefName = guid(resourceGroup().id)

resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: roleDefName
  properties: {
    roleName: '${resourceGroupName}-min-RW'
    description: roleDescription
    type: 'customRole'
    permissions: [
      {
        actions: actions
        notActions: notActions
        dataActions: dataActions
        notDataActions: notDataActions
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}
