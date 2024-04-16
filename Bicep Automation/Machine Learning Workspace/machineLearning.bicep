// Creates a machine learning workspace, private endpoints and compute resources
// Compute resources include a GPU cluster, CPU cluster, compute instance and attached private AKS cluster
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
@description('Virtual Network Name')
param vnetName string
@description('Virtual Netowork Id')
param vnetId string
@description('Resource ID of the application insights resource')
param applicationInsightsId string
@description('Resource ID of the container registry resource')
param containerRegistryId string
@description('Resource ID of the key vault resource')
param keyVaultId string
@description('Resource ID of the storage account resource')
param storageAccountId string
@description('Resource ID of the subnet resource')
param subnetRef string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Existing Machine Learning Private DNS Zone Id')
param existingMachineLearningPrivateDnsZoneId string
@description('Existing Notebook Private DNS Zone Id')
param existingNotebookPrivateDnsZoneId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Log Analytics Workspace Resource ID')
param workspaceId string

// variables
@description('Machine learning workspace name')
var machineLearningName = toLower('ml-${projectCode}-${environment}-workspace01')
@description('Machine learning workspace private link endpoint name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-workspace01')
@description('Machine learning workspace display name')
var machineLearningFriendlyName = replace(machineLearningName, '-', '')
//var machineLearningFriendlyName = machineLearningName
@description('Machine learning workspace description')
var machineLearningDescription = 'Machine Learning Workspace'
var privateDnsZoneName = {
  azureusgovernment: 'privatelink.api.ml.azure.us'
  azurechinacloud: 'privatelink.api.ml.azure.cn'
  azurecloud: 'privatelink.api.azureml.ms'
}
var privateAznbDnsZoneName = {
  azureusgovernment: 'privatelink.notebooks.usgovcloudapi.net'
  azurechinacloud: 'privatelink.notebooks.chinacloudapi.cn'
  azurecloud: 'privatelink.notebooks.azure.net'
}
@description('Network Access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
var pvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var settingName = 'Send to Log Analytics Workspace'

resource machineLearning 'Microsoft.MachineLearningServices/workspaces@2022-05-01' = {
  name: machineLearningName
  location: location
  tags: union({
      Name: machineLearningName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // workspace organization
    friendlyName: machineLearningFriendlyName
    description: machineLearningDescription
    // dependent resources
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    keyVault: keyVaultId
    storageAccount: storageAccountId
    // configuration for workspaces with private link endpoint
    imageBuildCompute: 'cluster001'
    hbiWorkspace: true
    publicNetworkAccess: publicNetworkAccess
  }
}

resource machineLearningPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
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
            'amlworkspace'
          ]
          privateLinkServiceId: machineLearning.id
        }
      }
    ]
    subnet: {
      id: subnetRef
    }
  }
}

resource amlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: privateDnsZoneName[toLower(az.environment().name)]
  tags: union({
      Name: privateDnsZoneName
    }, combineResourceTags)
  location: 'global'
}

resource amlPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: '${vnetName}-link'
  parent: amlPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// Notebook
resource notebookPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: privateAznbDnsZoneName[toLower(az.environment().name)]
  location: 'global'
}

resource notebookPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-link'
  parent: notebookPrivateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpointDns 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: pvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName[az.environment().name]
        properties: {
          //privateDnsZoneId: amlPrivateDnsZone.id
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? amlPrivateDnsZone.id : existingMachineLearningPrivateDnsZoneId
        }
      }
      {
        name: privateAznbDnsZoneName[az.environment().name]
        properties: {
          //privateDnsZoneId: notebookPrivateDnsZone.id
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? notebookPrivateDnsZone.id : existingNotebookPrivateDnsZoneId
        }
      }
    ]
  }
}

// Diagnostics Setting inside Container Registry
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: machineLearning
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

output machineLearningId string = machineLearning.id
