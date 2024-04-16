@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Cognitive Serivce Private DNS Zone Id')
param privateDnsZoneId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Cognitive Serivce Private DNS Zone Id')
param existingCognitiveServicePrivateDnsZoneId string
@description('Cognitive Service is already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false"')
@allowed([
  true
  false ])
param cognitiveServiceRestore bool

// parameter
@description('Data Subnet Id for Prviate Endpoint')
param subnetRef string

@description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name')
var cognitiveServiceName = toLower('cg${projectCode}-${environment}-speech01')
@description('That name is the name of our application. It has to be unique.Type a name followed by your resource group name')
var customDomainName = toLower('cg${projectCode}-${environment}-speech01')
/*@allowed([
  'S0'
  'F0'
])*/
var sku = 'S0'
@description('Form Recoginzer Public Access')
var publicNetworkAccess = networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(false) ? 'Disabled' : 'Enabled'
var networkAcls = {
  bypass: 'AzureServices'
  virtualNetworkRules: [
    {
      id: subnetRef
      action: 'Allow'
    }
  ]
  ipRules: []
  defaultAction: 'Deny'
}
@description('Key Vault Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-speech01')
@description('Network Interface Name for Key Vault Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}speech01')
var groupId = 'account'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var settingName = 'Send to Log Analytics Workspace'

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2021-10-01' = {
  name: cognitiveServiceName
  location: location
  tags: union({
      Name: cognitiveServiceName
    }, combineResourceTags)
  sku: {
    name: sku
  }
  kind: 'SpeechServices'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(true) ? networkAcls : null
    customSubDomainName: customDomainName
    restore: cognitiveServiceRestore
    apiProperties: {
      statisticsEnabled: false
    }
  }
}

// creation of Form Recognizer 
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: privateEndpointName
  location: location
  tags: union({
      Name: privateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: cognitiveService.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: customNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZoneId : existingCognitiveServicePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

// Diagnostics Setting inside Speech Cognitive Service
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: cognitiveService
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: null
        categoryGroup: 'Audit'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: null
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
