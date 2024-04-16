@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('App Service Plan Sku Type for Standard Logic APP')
@allowed([
  'WS1'
  'WS2'
  'WS3'
])
param logicAppAppServiceSkuVersion string
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
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Existing Storage Account ')
param storageAccountName string

// variables
@description('Public Network Access of storage account')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
@description('Aloow required Infrastructure Encryption')
var appServicePlanName = toLower('la-app-${projectCode}-${environment}-plan')
var logicAppName = toLower('la-${projectCode}-${environment}-mailalert01')
var applicationInsightsName = toLower('la-${projectCode}-${environment}-app-insight01')
var appKind = 'elastic'
var perSiteScaling = false
var maximumElasticWorkerCount = 20
var zoneRedundant = true
@description('Logic App Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-la01')
@description('Network Interface Name for Logic App Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}la01')
var skuReference = {
  WS1: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    size: 'WS1'
    family: 'WS'
    capacity: 3
  }
  WS2: {
    name: 'WS2'
    tier: 'WorkflowStandard'
    size: 'WS2'
    family: 'WS'
    capacity: 3
  }
  WS3: {
    name: 'WS3'
    tier: 'WorkflowStandard'
    size: 'WS3'
    family: 'WS'
    capacity: 3
  }
}
var groupId = 'sites'
var privateDnsZoneName = 'privatelink.azurewebsites.net'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var settingName = 'Send to Log Analytics Workspace'
//var netFrameworkVersion = 'v6.0'

// creation of Azure App Serive Plan (Standard Lofic APP)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: union({
      Name: appServicePlanName
    }, combineResourceTags)
  sku: skuReference[logicAppAppServiceSkuVersion]
  /*sku: {
    name: skuReference[appServiceSkuVersion].name
    tier: skuReference[appServiceSkuVersion].tier
    size: skuReference[appServiceSkuVersion].size
    family: skuReference[appServiceSkuVersion].family
    capacity: skuReference[appServiceSkuVersion].capacity
  }*/
  kind: appKind
  properties: {
    perSiteScaling: perSiteScaling
    maximumElasticWorkerCount: maximumElasticWorkerCount
    zoneRedundant: zoneRedundant
  }
}

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

resource logicApp 'Microsoft.Web/sites@2022-09-01' = {
  name: logicAppName
  location: location
  tags: union({
      Name: logicAppName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp,workflowapp'
  properties: {
    serverFarmId: appServicePlan.id
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
          value: 'node'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: logicAppName
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }

        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
      ]
      use32BitWorkerProcess: true
      cors: {
        allowedOrigins: [ 'https://portal.azure.com' ]
      }
      vnetRouteAllEnabled: true
    }
  }
}

/*resource logicApp 'Microsoft.Web/sites@2022-09-01' = {
  name: logicAppName
  location: location
  tags: union({
      Name: logicAppName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp,workflowapp'
  properties: {
    serverFarmId: appServicePlan.id
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
          value: 'node'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: logicAppName
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
}*/

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
          privateLinkServiceId: logicApp.id
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

// Diagnostics Setting inside Microsoft Azure Purview
resource appServicePanSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: appServicePlan
  properties: {
    workspaceId: workspaceId
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

// Diagnostics Setting inside Azure Logic App (Standard)
/*resource logicAppSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: logicApp
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'WorkflowRuntime'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
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
}*/

output webAppPrivateDnsZoneId string = privateDnsZone.id
