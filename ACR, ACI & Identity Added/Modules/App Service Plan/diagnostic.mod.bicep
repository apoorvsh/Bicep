@description('App Service Plan Name')
param appServicePlanName string
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''

@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
var retentionPolicyDays = 0
var settingName = 'Send to Log Analytics Workspace'

resource appServivePlan 'Microsoft.Web/serverfarms@2022-09-01' existing = {
  name: appServicePlanName
}

// Diagnostics Setting inside Microsoft Azure Purview
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: appServivePlan
  properties: {
    workspaceId: workspaceId
    storageAccountId: empty(storageAccountResourceId) ? null : storageAccountResourceId
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
