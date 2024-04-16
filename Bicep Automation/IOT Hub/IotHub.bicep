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
@description('Existing IOT Hub Private DNS Zone Id')
param existingIotHubPrivateDnsZoneId string
@description('Existing Service Bus Private DNS Zone Id')
param existingServiceBusPrivateDnsZoneId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Storage Account Name')
param storageAccountName string
@description('Storage Account Container Name')
param storageContainerName string
@description('Principal ID')
param principalId string
@description('Identity Id')
param identityId string

@description('The SKU to use for the IoT Hub.')
var sku = {
  name: 'S1'
  tier: 'Standard'
  capacity: 1
}
@description('IOT Hub Name')
var iotHubName = toLower('iot-${projectCode}-${environment}-hub01')
@description('Private Endpoint Name')
var privateEndpointName = toLower('pep-${projectCode}-${environment}-hub01')
@description('Private Endpoint Name NIC Name')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}hub01')
@description('Network Access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
@description('Target Resource IOT Hub')
var groupId = 'iotHub'
var iotHubPrivateDnsZoneName = 'privatelink.azure-devices.net'
var serviceBusPrivateDnsZoneName = 'privatelink.servicebus.windows.net'
var iotHubPvtEndpointDnsGroupName = '${privateEndpointName}/mydnsgroupname'
var storageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var settingName = 'Send to Log Analytics Workspace'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

resource storageAccountName_Microsoft_Authorization_id_storageBlobDataContributorRoleID_iotHub 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2018-09-01-preview' = {
  name: '${storageAccountName}/Microsoft.Authorization/${guid('${resourceGroup().id}/${storageBlobDataContributorRoleID}/${iotHubName}')}'
  location: location
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// if storage account is public then only the key based will work but if storage account is selected network or diable then UMI will work
resource iotHub 'Microsoft.Devices/IotHubs@2022-04-30-preview' = {
  name: iotHubName
  location: location
  dependsOn: [
    storageAccountName_Microsoft_Authorization_id_storageBlobDataContributorRoleID_iotHub
  ]
  tags: union({
      Name: iotHubName
    }, combineResourceTags)
  sku: sku
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    publicNetworkAccess: publicNetworkAccess
    ipFilterRules: []
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 4
      }
    }
    storageEndpoints: {
      '$default': {
        sasTtlAsIso8601: 'PT1H'
        connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        containerName: storageContainerName
        authenticationType: 'identityBased'
        identity: {
          // Grant Storage Blob Data Contributor to the UMI (User Assigned Managed Indentity)
          userAssignedIdentity: identityId
        }
      }
    }
    messagingEndpoints: {
      fileNotifications: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    enableFileUploadNotifications: true
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
      feedback: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    features: 'None'
    disableLocalAuth: false
    allowedFqdnList: []
    enableDataResidency: false
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
          privateLinkServiceId: iotHub.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: customNetworkInterfaceName
  }
}

resource iotHubPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: iotHubPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: iotHubPrivateDnsZoneName
    }, combineResourceTags)
}

resource iotHubPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: iotHubPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource serviceBusPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: serviceBusPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: serviceBusPrivateDnsZoneName
    }, combineResourceTags)
}

resource serviceBusPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: serviceBusPrivateDnsZone
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
  name: iotHubPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? iotHubPrivateDnsZone.id : existingIotHubPrivateDnsZoneId
        }
      }
      {
        name: 'config2'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? serviceBusPrivateDnsZone.id : existingServiceBusPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

// Diagnostics Setting inside IOT HUB
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: iotHub
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'null'
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'null'
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
