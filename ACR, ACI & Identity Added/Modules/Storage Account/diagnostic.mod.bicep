@description('Key Vault Name')
param storageAccountName string
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''

@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
var retentionPolicyDays = 0

var settingName = empty(storageAccountResourceId) ? 'Send logs to Log Analytics Workspace' : 'Send logs to Log Analytics Workspace and Storage Account'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Diagnostics Logs For Azure Storage Account
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: storageAccount
  properties: {
    workspaceId: workspaceId
    storageAccountId: empty(storageAccountResourceId) ? null : storageAccountResourceId
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}

// Diagnostics Logs for File Service Inside Storage Account
resource blob 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

// Diagnostics Logs For Blob Service inside Storage Account
resource blobSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: blob
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
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}

// Diagnostics Log for Table Service Inside Storage Account
resource table 'Microsoft.Storage/storageAccounts/tableServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource tableSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: table
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
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}

// Diagnostics Logs for File Service Inside Storage Account
resource file 'Microsoft.Storage/storageAccounts/fileServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource fileSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: file
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
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}

// Diagnostics Logs for Queue Service Inside Azure Storage Account
resource queue 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource queueSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: settingName
  scope: queue
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
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}
