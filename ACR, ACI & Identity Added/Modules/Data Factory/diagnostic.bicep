@description('Azure Data Factory Name')
param dataFactoryName string
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''

@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
var retentionPolicyDays = 0
var settingName = empty(storageAccountResourceId) ? 'Send log to Log Analytics Workspace' : 'Send log to Log Analytics Workspace and Storage Account'

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

// Diagnostics Setting inside Azure Data Factory
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: datafactory
  properties: {
    workspaceId: workspaceId
    storageAccountId: empty(storageAccountResourceId) ? null : storageAccountResourceId
    logs: [
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
