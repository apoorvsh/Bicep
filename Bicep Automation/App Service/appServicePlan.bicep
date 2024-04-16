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
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int

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
var settingName = 'Send to Log Analytics Workspace'

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

// Diagnostics Setting inside Microsoft Azure Purview
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
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

output appServicePlanId string = appServicePlan.id
