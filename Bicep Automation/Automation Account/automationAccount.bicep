@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string
@description('Existing Azure Automation Private Dns Zone id')
param existingAutomationPrivateDnsZoneId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int


// parameter
@description('Data Subnet Id for Prviate Endpoint')
param subnetRef string

var accountname = toLower('auto-${projectCode}-${environment}-account01')
var webHookPrivateEndpointName = toLower('pep-${projectCode}-${environment}-webhook01')
var hybridWorkerPrivateEndpointName = toLower('pep-${projectCode}-${environment}-hybridWorker01')
var webHookCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}webhook01')
var hybridWorkerCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}hybridworker01')
var webHookGroupId = 'Webhook'
var hybridWorkerGroupId = 'DSCAndHybridWorker'
@description('Automation Account Network access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? false : true
var disableLocalAuth = false
var sku = {
  capacity: null
  family: null
  name: 'Basic'
}
var privateDnsZoneName = 'privatelink.azure-automation.net'
var webHookPvtEndpointDnsGroupName = '${webHookPrivateEndpointName}/mydnsgroupname'
var hybridWorkerPvtEndpointDnsGroupName = '${hybridWorkerPrivateEndpointName}/mydnsgroupname'
var settingName = 'Send to Log Analytics Workspace'

resource autaccount 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: accountname
  location: location
  tags: union({
      Name: accountname
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: disableLocalAuth
    encryption: {
      identity: {}
      keySource: 'Microsoft.Automation'
    }
    publicNetworkAccess: publicNetworkAccess
    sku: sku
  }
}

// creation of Azure Automation Account private endpoint
resource webHookPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: webHookPrivateEndpointName
  location: location
  tags: union({
      Name: webHookPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: webHookPrivateEndpointName
        properties: {
          privateLinkServiceId: autaccount.id
          groupIds: [
            webHookGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: webHookCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

// creation of key vault private endpoint
resource hybridWorkerPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: hybridWorkerPrivateEndpointName
  location: location
  tags: union({
      Name: hybridWorkerPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: webHookPrivateEndpointName
        properties: {
          privateLinkServiceId: autaccount.id
          groupIds: [
            hybridWorkerGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: hybridWorkerCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: privateDnsZoneName
    }, combineResourceTags)
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: privateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource webHookPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: webHookPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZone.id : existingAutomationPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    webHookPrivateEndpoint
  ]
}

resource hybridWokerPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: hybridWorkerPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZone.id : existingAutomationPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    hybridWorkerPrivateEndpoint
  ]
}

// Diagnostics Setting inside Azure Automation
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: autaccount
  properties: {
    workspaceId: workspaceId
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

