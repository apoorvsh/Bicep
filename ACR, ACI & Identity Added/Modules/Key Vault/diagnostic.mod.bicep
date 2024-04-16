@description('Key Vault Name')
param keyVaultName string
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''

@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
var retentionPolicyDays = 0
var settingName = empty(storageAccountResourceId) ? 'Send to Log Analytics Workspace' : 'Send to Log Analytics Workspace and Storage Account'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Diagnostics Setting inside Key Vault
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: keyVault
  properties: {
    workspaceId: workspaceId
    storageAccountId: empty(storageAccountResourceId) ? null : storageAccountResourceId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}
