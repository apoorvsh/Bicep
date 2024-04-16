// Creates an Azure Container Registry with Azure Private Link endpoint
// Global parameters
@description('Define the project name or prefix for all objects.')
@minLength(1)
@maxLength(11)
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Referencing Subnet Id')
param subnetRef string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Virtual Network Name')
param vnetName string
@description('Virtual Netowork Id')
param vnetId string
@description('Container Registry Sku "Private access (Recommended) is only available for Premium SKU."')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param continerRegistrySku string
@description('Existing Container Registry Private DNS Zone Id')
param existingContainerRegistryPrivateDnsZoneId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int

@description('Container registry name')
var containerRegistryName = toLower('con-${projectCode}-${environment}-registry01')
@description('Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-registry01')
var containerRegistryNameCleaned = replace(containerRegistryName, '-', '')
var privateDnsZoneName = 'privatelink${az.environment().suffixes.acrLoginServer}'
var groupName = 'registry'
var registrySku = {
  name: continerRegistrySku
}
@description('Network Access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
@description('Zone Redundancy Enabled or Disabled')
var zoneRedundancy = 'Enabled'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var settingName = 'Send to Log Analytics Workspace'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryNameCleaned
  location: location
  tags: union({
      Name: containerRegistryNameCleaned
    }, combineResourceTags)
  sku: registrySku
  properties: {
    adminUserEnabled: true
    dataEndpointEnabled: false
    networkRuleBypassOptions: 'AzureServices'
    networkRuleSet: {
      defaultAction: 'Deny'
    }
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 7
      }
      trustPolicy: {
        status: 'disabled'
        type: 'Notary'
      }
    }
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: zoneRedundancy
  }
}

resource containerRegistryPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: privateEndpointName
  location: location
  tags: union({
      Name: privateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          groupIds: [
            groupName
          ]
          privateLinkServiceId: containerRegistry.id
        }
      }
    ]
    subnet: {
      id: subnetRef
    }
  }
}
resource acrPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: privateDnsZoneName
  tags: union({
      Name: privateDnsZoneName
    }, combineResourceTags)
  location: 'global'
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? acrPrivateDnsZone.id : existingContainerRegistryPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    containerRegistryPrivateEndpoint
  ]
}

resource acrPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: acrPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Diagnostics Setting inside Container Registry
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: containerRegistry
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        categoryGroup: 'audit'
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

output containerRegistryId string = containerRegistry.id
