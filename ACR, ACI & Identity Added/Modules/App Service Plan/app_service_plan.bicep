@description('App Service Plan Name')
param appServicePlanName string
@description('Resource Tags')
param resourceTags object
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

var perSiteScaling = false
var maximumElasticWorkerCount = 20
var reserved = appServiceOsVersion == 'Linux' ? true : false
var appKind = appServiceOsVersion == 'Linux' ? 'linux' : 'app'
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

// creation of Azure App Serive Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: resourceTags
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

output appServicePlanId string = appServicePlan.id
