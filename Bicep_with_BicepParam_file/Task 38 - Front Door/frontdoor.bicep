param storageAccountName string
param storageAccountSku string 
param location string
param kind string
param accessTier string
param frontDoorProfileName string
param frontDoorSkuName string
param frontDoorEndpointName string
param frontDoorOriginGroupName string
param frontDoorOriginName string
param wafPolicyName string
param frontDoorRouteName string

var networkAcls = {
  bypass: 'AzureServices'
  virtualNetworkRules: []
  ipRules: []
  defaultAction: 'Allow'
}

var publicNetworkAccess = 'Enabled'
var allowBlobPublicAccess = true




resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: kind
  properties: {
    publicNetworkAccess: publicNetworkAccess
    allowBlobPublicAccess: allowBlobPublicAccess
    isHnsEnabled: true
    accessTier: accessTier
    networkAcls: networkAcls 
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: frontDoorProfileName
   
  location: 'global'
  sku: {
    name: frontDoorSkuName
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: frontDoorEndpointName
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: frontDoorOriginGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Http'
      probeIntervalInSeconds: 100
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: frontDoorOriginName
  parent: frontDoorOriginGroup
  properties: {
    hostName: '${storageAccountName}.blob.core.windows.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: '${storageAccountName}.blob.core.windows.net'
    priority: 1
    weight: 1000
  }
}

resource wafPolicy 'Microsoft.Network/frontdoorwebapplicationfirewallpolicies@2020-11-01' = {
  name: wafPolicyName
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Detection'
    }
  }
  location: 'Global'
  sku: {
    name: frontDoorSkuName
  }
}

resource frontDoorName_wafPolicyName_id 'Microsoft.Cdn/Profiles/SecurityPolicies@2022-11-01-preview' = {
  parent: frontDoorProfile
  name: '${wafPolicyName}-${uniqueString(resourceGroup().id)}'
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: wafPolicy.id
      }
      associations: [
        {
          domains: [
            {
              id: frontDoorEndpoint.id
            }
          ]
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}

resource frontDoorName_frontDoorEndpointName_frontDoorRoute 'Microsoft.Cdn/Profiles/AfdEndpoints/Routes@2022-11-01-preview' = {
  parent: frontDoorEndpoint
  name: frontDoorRouteName
  properties: {
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
 
}
