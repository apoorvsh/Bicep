@description('Combine Resources Tags')
param resourceTags object
@description('Resource Location')
param location string
@description('Network Access Approach')
@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string
param functionAppName string
param appServicePlanId string
param applicationInsightInstrumentationKey string
@description('App Serive OS Version')
@allowed([
  'Linux'
  'Window'
])
param appServiceOsVersion string

@description('Existing Storage Account ')
param storageAccountName string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param appSubnetName string

var outboundSubnetId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${appSubnetName}'
@description('Public Network Access of storage account')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlanId
    enabled: true
    clientAffinityEnabled: false
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkSubnetId: networkAccessApproach == 'Public' ? null : outboundSubnetId
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightInstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }

      ]
      cors: {
        allowedOrigins: [ 'https://portal.azure.com' ]
      }
      use32BitWorkerProcess: true
      vnetRouteAllEnabled: true
      linuxFxVersion: appServiceOsVersion == 'Linux' ? 'DOTNETCORE|7.0' : null
      netFrameworkVersion: appServiceOsVersion == 'Window' ? 'v7.0' : null
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      alwaysOn: true
    }
    httpsOnly: true
  }
}
