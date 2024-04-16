param apiManagementName string
param publisherEmail string
param publisherName string
@description('Resource Tags')
param resourceTags object
@description('Resource Location')
param location string
@description('If already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false", "Only API Management services deleted within the last 48 hours can be recovered."')
param apimRestore bool = false
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@allowed([
  'Internal'
  'External'
])
param virtualNetworkType string
param publicIpId string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('APIM Subnet Name')
param apimSubnetName string
@description('Appication Insight Name')
param appInsightsName string
@description('Application Insight Resource ID')
param appInsightsId string
@description('Application Insight Instrument Key')
param appInsightsInstrumentationKey string

var sku = {
  capacity: 1
  name: 'Premium'
}

var virtualNetworkConfiguration = {
  subnetResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${vnetResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${apimSubnetName}'
}

resource api_Management_Instance 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apiManagementName
  location: location
  tags: resourceTags
  sku: sku
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicIpAddressId: !empty(virtualNetworkType) && contains(networkAccessApproach, 'Public') ? publicIpId : null
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: !empty(virtualNetworkType) && contains(networkAccessApproach, 'Public') ? virtualNetworkType : 'None'
    restore: apimRestore
    virtualNetworkConfiguration: !empty(virtualNetworkType) && contains(networkAccessApproach, 'Public') ? virtualNetworkConfiguration : null
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${apiManagementName}.azure-api.net'
        negotiateClientCertificate: false
        defaultSslBinding: false
        certificateSource: 'BuiltIn'
      }
    ]
  }
}

resource apimName_appInsightsLogger_resource 'Microsoft.ApiManagement/service/loggers@2023-03-01-preview' = {
  parent: api_Management_Instance
  name: appInsightsName
  properties: {
    loggerType: 'applicationInsights'
    resourceId: appInsightsId
    isBuffered: true
    credentials: {
      instrumentationKey: appInsightsInstrumentationKey
    }
  }
}

output apimID string = api_Management_Instance.id
