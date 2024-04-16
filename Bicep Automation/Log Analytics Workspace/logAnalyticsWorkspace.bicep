@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Log Analytics WorkSpace Pricing Tier')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param pricingTier string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int

var dataRetention = 360
var immediatePurgeDataOn30Days = true
var workSpaceName = toLower('log-${projectCode}-${environment}-analytics01')
var settingName = 'Send to Log Analytics Workspace'

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: workSpaceName
  location: location
  tags: union({
      Name: workSpaceName
    }, combineResourceTags)
  properties: {
    retentionInDays: dataRetention
    features: {
      immediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    }
    sku: {
      name: pricingTier
    }
  }
}

// Diagnostics Setting AZure log Analytics
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  dependsOn: [ workspace]
  scope: workspace
  properties: {
    workspaceId: workspace.id
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

output deCentralizedWorkspaceId string = workspace.id
