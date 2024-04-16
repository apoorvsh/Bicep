// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string
@description('Existing Blob Private DNS Zone of Storage Account')
param existingBlobPrivateDnsZoneId string
@description('Existing Dfs Private DNS Zone of Storage Account')
param existingDfsPrivateDnsZoneId string
@description('Existing Queue Private DNS Zone of Storage Account')
param existingQueuePrivateDnsZoneId string
@description('Existing File Private DNS Zone of Storage Account')
param existingFilePrivateDnsZoneId string
@description('Existing Table Private DNS Zone of Storage Account')
param existingTablePrivateDnsZoneId string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool
param blobPrivateDnsZoneId string
param queuePrivateDnsZoneId string
param filePrivateDnsZoneId string
param tablePrivateDnsZoneId string

// parameter
@description('Data Subnet Id for Prviate Endpoint')
param subnetRef string

// variables
@description('Azure Data Lake Gen2 Bronze Storage Account Name')
var storageAccountName = toLower('dls${projectCode}${environment}store01')
@description('Adls Storage Kind')
var storageAccountKind = 'StorageV2'
@description('Storage Account Sku')
var storageAccountSku = 'Standard_LRS'
@description('Storage Account Access Tier')
var storageAccountAccessTier = 'Hot'
@description('Blob Private Endpoint Name')
var blobStoragePrivateEndpointName = toLower('pep-${projectCode}-${environment}-blob02')
@description('Network Interface Name for Storage Account Private Endpoint')
var blobCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}blob02')
@description('Queue Private Endpoint Name')
var queueStoragePrivateEndpointName = toLower('pep-${projectCode}-${environment}-queue02')
@description('Network Interface Name for Storage Account Private Endpoint')
var queueCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}queue02')
@description('File Private Endpoint Name')
var fileStoragePrivateEndpointName = toLower('pep-${projectCode}-${environment}-file02')
@description('Network Interface Name for Storage Account Private Endpoint')
var fileCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}file02')
@description('Table Private Endpoint Name')
var tableStoragePrivateEndpointName = toLower('pep-${projectCode}-${environment}-table02')
@description('Network Interface Name for Storage Account Private Endpoint')
var tableCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}table02')
@description('Dfs Private Endpoint Name')
var dfsStoragePrivateEndpointName = toLower('pep-${projectCode}-${environment}-dfs02')
@description('Network Interface Name for Storage Account Private Endpoint')
var dfsCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}dfs02')
@description('Target Sub Resource of Storage Account')
var blobGroupId = 'blob'
@description('Target Sub Resource of Storage Account')
var dfsGroupId = 'dfs'
@description('Target Sub Resource of Storage Account')
var queueGroupId = 'queue'
@description('Target Sub Resource of Storage Account')
var fileGroupId = 'file'
@description('Target Sub Resource of Storage Account')
var tableGroupId = 'table'
@description('Allow Blob Public Access')
var allowBlobPublicAccess = true
@description('Allow cross Tenanat Replication')
var allowCrossTenantReplication = true
@description('Allow Shared Key Access')
var allowSharedKeyAccess = true
@description('Public Network Access of storage account')
var publicNetworkAccess = networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(false) ? 'Disabled' : 'Enabled'
@description('Aloow required Infrastructure Encryption')
var requireInfrastructureEncryption = true
@description('Allow storage account to behave as ADLS Gen2 storage account')
var isHnsEnabled = true
@description('Allow NFsV3')
var isNfsV3Enabled = false
@description('Minimum TLS Version')
var minimumTlsVersion = 'TLS1_2'
@description('Large File Shares State')
var largeFileSharesState = 'Disabled'
@description('Allow Https Traffic Only')
var supportsHttpsTrafficOnly = true
@description('Allow Container Delete Retention Policy')
var containerDeleteRetentionPolicy = true
@description('Container Delete Retention Policy Days')
var containerDeleteRetentionPolicyDays = 7
@description('Allow Blob Delete Retention Policy')
var blobDeleteRetentionPolicy = true
@description('Blob Delete Retention Policy Days')
var blobDeleteRetentionPolicyDays = 7
var blobPvtEndpointDnsGroupName = '${blobStoragePrivateEndpointName}/mydnsgroupname'
var dfsPrivateDnsZoneName = 'privatelink.dfs.${az.environment().suffixes.storage}'
var dfsPvtEndpointDnsGroupName = '${dfsStoragePrivateEndpointName}/mydnsgroupname'
var queuePvtEndpointDnsGroupName = '${queueStoragePrivateEndpointName}/mydnsgroupname'
var filePvtEndpointDnsGroupName = '${fileStoragePrivateEndpointName}/mydnsgroupname'
var tablePvtEndpointDnsGroupName = '${tableStoragePrivateEndpointName}/mydnsgroupname'
var networkAcls = {
  bypass: 'Logging, Metrics, AzureServices'
  virtualNetworkRules: [
    {
      id: subnetRef
      action: 'Allow'
    }
  ]
  ipRules: []
  defaultAction: 'Deny'
}
var containerName = [
  toLower('synw-${projectCode}-${environment}-raw01')
  toLower('iot-${projectCode}-${environment}-store01')
]
var fileShareName = [
  toLower('file-${projectCode}-${environment}-app01')
]
@description('Blob Public Access')
var blobPublicAccess = 'None'

// creation of storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: union({
      Name: storageAccountName
    }, combineResourceTags)
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  properties: {
    accessTier: storageAccountAccessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    allowSharedKeyAccess: allowSharedKeyAccess
    publicNetworkAccess: publicNetworkAccess
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: requireInfrastructureEncryption
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: isHnsEnabled
    isNfsV3Enabled: isNfsV3Enabled
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: largeFileSharesState
    minimumTlsVersion: minimumTlsVersion
    networkAcls: networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(true) ? networkAcls : null
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
  }
}

// creation of soft delete for conatainer and blob in storage account
resource blob 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: containerDeleteRetentionPolicy
      days: containerDeleteRetentionPolicyDays
    }
    deleteRetentionPolicy: {
      enabled: blobDeleteRetentionPolicy
      days: blobDeleteRetentionPolicyDays
    }
  }
}

// creation of container inside azure storage account
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for name in containerName: {
  name: '${storageAccount.name}/default/${name}'
  properties: {
    publicAccess: blobPublicAccess
  }
}]

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = [for name in fileShareName: {
  name: '${storageAccount.name}/default/${name}'
  properties: {}
}]

// creation of storage account private endpoint for blob
resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: blobStoragePrivateEndpointName
  location: location
  tags: union({
      Name: blobStoragePrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: blobStoragePrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            blobGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: blobCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource blobPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: blobPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? blobPrivateDnsZoneId : existingBlobPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    blobPrivateEndpoint
  ]
}

// creation of storage account private endpoint for dfs
resource dfsPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: dfsStoragePrivateEndpointName
  location: location
  tags: union({
      Name: dfsStoragePrivateEndpointName
    }, combineResourceTags)
  dependsOn: [
    blobPrivateEndpoint
  ]
  properties: {
    privateLinkServiceConnections: [
      {
        name: dfsStoragePrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            dfsGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: dfsCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource dfsPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: dfsPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: dfsPrivateDnsZoneName
    }, combineResourceTags)
}

resource dfsPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: dfsPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource dfsPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: dfsPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? dfsPrivateDnsZone.id : existingDfsPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    dfsPrivateEndpoint
  ]
}

// creation of storage account private endpoint for Queue
resource queuePrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: queueStoragePrivateEndpointName
  location: location
  dependsOn: [ dfsPrivateEndpoint ]
  tags: union({
      Name: queueStoragePrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: queueStoragePrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            queueGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: queueCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource queuePvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: queuePvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? queuePrivateDnsZoneId : existingQueuePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    queuePrivateEndpoint
  ]
}

// creation of storage account private endpoint for File
resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: fileStoragePrivateEndpointName
  location: location
  dependsOn: [ queuePrivateEndpoint ]
  tags: union({
      Name: fileStoragePrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: fileStoragePrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            fileGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: fileCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource filePvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: filePvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? filePrivateDnsZoneId : existingFilePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    filePrivateEndpoint
  ]
}

// creation of storage account private endpoint for Table
resource tablePrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: tableStoragePrivateEndpointName
  dependsOn: [ filePrivateEndpoint ]
  location: location
  tags: union({
      Name: tableStoragePrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: tableStoragePrivateEndpointName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            tableGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: tableCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource tablePvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: tablePvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? tablePrivateDnsZoneId : existingTablePrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    tablePrivateEndpoint
  ]
}

output storageAccountName string = storageAccount.name
output storageAccountId string = storageAccount.id
output synapseContainerName string = containerName[0]
output iotHubContainerName string = containerName[1]
output storageEndpoint string = storageAccount.properties.primaryEndpoints.blob
