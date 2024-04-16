@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('outboundSubnetId for Vnet Integration inside Standard Logic App')
param outboundSubnetId string
@description('Data Subnet Id for Prviate Endpoint')
param subnetRef string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string
@description('Existing Key Vault Private DNS Zone')
param existingWebAppPrivateDnsZoneId string
@description('App Serice Plan ID')
param appServicePlanId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int

// variables
@description('Public Network Access of storage account')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
var webAppName = toLower('web-${projectCode}-${environment}-app01')
var applicationInsightsName = toLower('web-${projectCode}-${environment}-app-insight01')
@description('Logic App Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-app01')
@description('Network Interface Name for Logic App Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}app01')
var groupId = 'sites'
var privateDnsZoneName = 'privatelink.azurewebsites.net'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var netFrameworkVersion = 'v6.0'
var settingName = 'Send to Log Analytics Workspace'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: union({
      Name: applicationInsightsName
    }, combineResourceTags)
  kind: 'web'
  properties: {
    WorkspaceResourceId: workspaceId
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  tags: union({
      Name: webAppName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'app,linux,container'
  properties: {
    serverFarmId: appServicePlanId
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetId: networkAccessApproach == 'Public' ? null : outboundSubnetId
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: webAppName
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
      ]
      cors: {
        allowedOrigins: [ 'https://portal.azure.com' ]
      }
      use32BitWorkerProcess: true
      vnetRouteAllEnabled: true
      netFrameworkVersion: netFrameworkVersion
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-11-01' = if (networkAccessApproach == 'Private') {
  name: privateEndpointName
  location: location
  tags: union({
      Name: privateEndpointName
    }, combineResourceTags)
  properties: {
    subnet: {
      id: subnetRef
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: webApp.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: customNetworkInterfaceName
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

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZone.id : existingWebAppPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

// Diagnostics Setting inside Azure Web App
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: webApp
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AppServiceAntivirusScanAuditLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'AppServiceAppLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'AppServiceFileAuditLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'AppServiceAuditLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'AppServiceIPSecAuditLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'AppServicePlatformLogs'
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

output privateDnsZoneId string = privateDnsZone.id
