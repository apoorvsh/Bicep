@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('App Service Plan Sku Type')
@allowed([
  'Basic'
  'Standard'
  'PremiumV2'
  'PremiumV3'
])
param appServiceSkuVersion string
@description('App Serive OS Version')
@allowed([
  'Linux'
  'Window'
])
param appServiceOsVersion string
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
@description('Existing Storage Account ')
param storageAccountName string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string

var perSiteScaling = false
var maximumElasticWorkerCount = 20
var reserved = appServiceOsVersion == 'Linux' ? true : false
var appKind = appServiceOsVersion == 'Linux' ? 'linux' : 'app'
var appServicePlanName = appServiceOsVersion == 'Window' ? toLower('plan-${projectCode}-${environment}-window') : toLower('plan-${projectCode}-${environment}-linux')
var zoneRedundant = false
//Azure Application Service Plan sizing
var skuReference = {
  Basic: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  Standard: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  PremiumV2: {
    name: 'P2v2'
    tier: 'PremiumV3'
    size: 'P2v2'
    family: 'Pv2'
    capacity: 1
  }
  PremiumV3: {
    name: 'P2v3'
    tier: 'PremiumV3'
    size: 'P2v3'
    family: 'Pv3'
    capacity: 1
  }
}
@description('Public Network Access of storage account')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
var functionAppName = toLower('fun-${projectCode}-${environment}-app01')
var applicationInsightsName = toLower('fun-${projectCode}-${environment}-app-insight01')
@description('Logic App Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-fun01')
@description('Network Interface Name for Logic App Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}fun01')
var groupId = 'sites'
var netFrameworkVersion = 'v6.0'
var privateDnsZoneName = 'privatelink.azurewebsites.net'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'

// creation of Azure App Serive Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: union({
      Name: appServicePlanName
    }, combineResourceTags)
  sku: skuReference[appServiceSkuVersion]
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
    reserved: reserved
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
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  dependsOn: [
    applicationInsights
  ]
  tags: union({
      Name: functionAppName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
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
