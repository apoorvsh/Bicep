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
@description('Existing Key Vault Private DNS Zone')
param existingWebAppPrivateDnsZoneId string
@description('Azure Web App private DNS Zone ID')
param privateDnsZoneId string
@description('Existing Storage Account ')
param storageAccountName string
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
var functionAppName = toLower('fun-${projectCode}-${environment}-app01')
var applicationInsightsName = toLower('fun-${projectCode}-${environment}-app-insight01')
@description('Logic App Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-fun01')
@description('Network Interface Name for Logic App Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}fun01')
var groupId = 'sites'
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

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  tags: union({
      Name: functionAppName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlanId
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetId: networkAccessApproach == 'Public' ? null : outboundSubnetId
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
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
          value: functionAppName
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
      alwaysOn: true
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
          privateLinkServiceId: functionApp.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: customNetworkInterfaceName
  }
}

resource pvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? privateDnsZoneId : existingWebAppPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

// Diagnostics Setting inside Azure Function APP
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: functionApp
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'FunctionAppLogs'
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
