@description('Virtual Network Name')
param vnetName string = ''
@description('Network Security Group Name')
param nsgName array = []
@description('Virtual Network Name')
param publicIpName string = ''
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''

@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
var retentionPolicyDays = 0
var settingName = 'Send logs to Log Analytics Workspace'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' existing = {
  name: publicIpName
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = [for i in range(0, length(nsgName)): {
  name: nsgName[i]
}]

resource vnet_setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(vnetName)) {
  name: settingName
  scope: virtualNetwork
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

resource nsg_setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for i in range(0, length(nsgName)): if (!empty(nsgName)) {
  name: settingName
  scope: networkSecurityGroup[i]
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
  }
}]

resource publicIP_setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(publicIpName)) {
  name: settingName
  scope: publicIp
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
