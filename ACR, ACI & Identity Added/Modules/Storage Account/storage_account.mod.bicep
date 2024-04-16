@description('Tags for the resources')
param resourceTags object
@description('Resource Location')
param location string
@description('Storage Account Name')
param storageAccountName string
@description('Network Access Public or Private')
@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string = 'Public'
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
@description('Storage Account Sku')
param storageAccountSku string
@description('Allow storage account to behave as ADLS Gen2 storage account')
param isHnsEnabled bool = false
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool = false

// variables
@description('Adls Storage Kind')
var storageAccountKind = 'StorageV2'
@description('Storage Account Access Tier')
var storageAccountAccessTier = 'Hot'
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
@description('Allow NFsV3')
var isNfsV3Enabled = false
@description('Minimum TLS Version')
var minimumTlsVersion = 'TLS1_2'
@description('Large File Shares State')
var largeFileSharesState = 'Disabled'
@description('Allow Https Traffic Only')
var supportsHttpsTrafficOnly = true
var containerDeleteRetentionPolicy = true
var blobDeleteRetentionPolicy = true
var containerDeleteRetentionPolicyDays = 180
var blobDeleteRetentionPolicyDays = 180

// creation of storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: resourceTags
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
    networkAcls: {
      bypass: 'Logging, Metrics, AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: allowPulicAccessFromSelectedNetwork == bool(true) ? 'Deny' : 'Allow'
    }
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
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

output storageAccountID string = storageAccount.id
