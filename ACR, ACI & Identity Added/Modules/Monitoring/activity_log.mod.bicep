targetScope = 'subscription'

@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''

var activityLogDiagnosticSettingsName = 'Send logs to Log Analytics Workspace'

resource subscriptionActivityLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: activityLogDiagnosticSettingsName
  properties: {
    storageAccountId: empty(storageAccountResourceId) ? null : storageAccountResourceId
    workspaceId: workspaceId
    logs: [
      {
        category: 'Administrative'
        enabled: true
      }
      {
        category: 'Security'
        enabled: true
      }
      {
        category: 'ServiceHealth'
        enabled: true
      }
      {
        category: 'Alert'
        enabled: true
      }
      {
        category: 'Recommendation'
        enabled: true
      }
      {
        category: 'Policy'
        enabled: true
      }
      {
        category: 'Autoscale'
        enabled: true
      }
      {
        category: 'ResourceHealth'
        enabled: true
      }
    ]
  }
}
