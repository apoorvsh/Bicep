
param name string
param location string
param hostingPlanName string

param alwaysOn bool
param ftpsState string
param sku string
param skuCode string

param linuxFxVersion string

resource appServiceSite 'Microsoft.Web/sites@2018-11-01' = {
  name: name
  location: location
  tags: {}
  
  properties: {
    siteConfig: {
      appSettings: []
      linuxFxVersion: linuxFxVersion
      alwaysOn: alwaysOn
      ftpsState: ftpsState
    }
    serverFarmId: appServicePlan.id
    clientAffinityEnabled: false
    
    httpsOnly: true
    
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  tags: {}
  dependsOn: []
  properties: {
    
    reserved: true
    zoneRedundant: false
  }
  sku: {
    tier: sku
    name: skuCode
  }
}
