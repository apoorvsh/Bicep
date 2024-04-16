
param name string
param location string
param use32BitWorkerProcess bool
param ftpsState string
param storageAccountName string
param linuxFxVersion string
param sku string
param skuCode string
param applicationInsightsName string

param dockerRegistryStartupCommand string
param hostingPlanName string

resource applicationInsights 'microsoft.insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: {
    'hidden-link:${resourceId('Microsoft.Web/sites', applicationInsightsName)}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
  }
  kind: 'web'
}

resource appService 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  location: location
  kind: 'functionapp,linux'
  properties: {
    
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(applicationInsights.id, '2015-05-01').InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value}'
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
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '0'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: use32BitWorkerProcess
      ftpsState: ftpsState
      linuxFxVersion: linuxFxVersion
      appCommandLine: dockerRegistryStartupCommand
    }
    clientAffinityEnabled: false
    
    httpsOnly: true
    serverFarmId: serverFarm.id//'/subscriptions/${subscriptionId}/resourcegroups/${serverFarmResourceGroup}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
  }
  
}

resource serverFarm 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  properties: {
    
    reserved: true
    maximumElasticWorkerCount: 20
    zoneRedundant: false
  }
  sku: {
    tier: sku
    name: skuCode
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  kind: 'BlobStorage'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    defaultToOAuthAuthentication: true
    accessTier: 'Hot'
  }
}


