param keyVaultName string
param vnetName string
param vnetAddress string
param vnetTagName object
param subnetName string
param subnetAddress string
param keyVaultTagName object
param enabledForDeployment bool
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool
param objectId string
param keysPermission string
param secretsPermission string
param keyVaultSkuName string
param keyVaultSkuFamily string
param keyVaultNameA string
@secure()
param sqlAdminUserName string
param keyVaultNameB string
@secure()
param sqlPassword string
param keyVaultPrivateEndpointName string
param keyVaultPrivateEndpointTagName object
param keyVaultPrivateLinkServiceConnectionsName string
param keyVaultGroupId string
param keyVaultDnsZoneName string
param keyVaultDnsZoneLocation string
param keyVaultDnsZoneTagName object
param keyVaultVnetLinkLocation string
param keyVaultRegistrationEnabled bool
param keyVaultPrivateDnsZoneConfigs string
param storageName string
param storageAccountTagName object
param storageKind string
param storageSku string
param storageAccessTier string
param allowBlobPublicAccess bool
param allowSharedKeyAccess bool
param ishnsEnabled  bool
param blobEnabled bool
param fileEnabled bool
param queueEnabled bool
param tableEnabled bool
param storageAccountPrivateEndpointName string
param storageAccountPrivateEndpointTagName object
param storageAccountPrivateLinkServiceConnectionsName string
param storageAccountGroupId string
param storageAccountDnsZoneName string
param storageAccountDnsZoneTagName object
param storageAccountDnsZoneLocation string
param storageAccountVnetLinkLocation string
param storageAccountRegistrationEnabled bool
param storageAcccountPrivateDnsZoneConfigs string
param synapseName string
param synapseTagName object
param storageAccountUrl string
param fileSystemName string
param synapsePrivateEndpointName string
param synapsePrivateEndpointTagName object
param synapsePrivateLinkServiceConnectionsName string
param synapseGroupId string
param synapseDnsZoneName string
param synapseDnsZoneLocation string
param synapseDnsZoneTagName object 
param synapseVnetLinkLocation string
param synapseRegistrationEnabled bool
param synapsePrivateDnsZoneConfigs string
param synapsePrivateLinkHubName string
param synapsePrivateLinkHubTagName object
param synapsePrivateLinkHubEndpointName string
param synapsePrivateLinkHubEndpointTagName object
param synapsePrivateLinkHubGroupId string
param synapsePrivateLinkHubDnsZoneName string
param synapsePrivateLinkHubDnsZoneLocation string
param synapsePrivateLinkHubDnsZoneTagName object
param synapsePrivateLinkHubVnetLinkLocation string
param synapsePrivateLinkHubRegistrationEnabled bool
param synapsePrivateLinkHubPrivateDnsZoneConfigs string
param synapsePrivateLinkHubPrivateLinkServiceConnectionsName string
param dedicatedSqlPoolName string
param dedicatedSqlPoolTagName object
param dedicatedSqlPoolSkuCapacity int
param dedicatedSqlPoolSkuName string
param dedicatedSqlPoolSkuTier string
param dedicatedSqlPoolPrivateEndpointName string
param dedicatedSqlPoolPrivateEndpointTagName object
param dedicatedSqlPoolPrivateLinkServiceConnectionsName string
param dedicatedSqlPoolGroupId string
param dedicatedSqlPoolDnsZoneName string
param dedicatedSqlPoolDnsZoneLocation string
param dedicatedSqlPoolDnsZoneTagName object
param dedicatedSqlPoolVnetLinkLocation string
param dedicatedSqlPoolRegistrationEnabled bool
param dedicatedSqlPoolPrivateDnsZoneConfigs string
param apacheSparkPoolName string
param apacheSparkPoolTagName object
param sparkNodeSize string
param sparkPoolNodeSizeFamily string
param sparkPoolDelayInMinutes int
param sparkPoolAutoPauseEnable bool
param sparkPoolAutoScaleEnable bool
param sparkPoolMaxNodeCount int
param sparkPoolMinNodeCount int
param saprkPoolDynamicExecutorAllocation bool
param sparkVersion string

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

module synapse './combine.bicep' = {
  name: 'moduleA'
  scope : resourceGroup('spokerg')
  params: {
    vnetName: vnetName
    vnetAddress: vnetAddress
    vnetTagName: vnetTagName
    subnetName: subnetName
    subnetAddress: subnetAddress
    keyVaultName: keyVaultName
    keyVaultTagName: keyVaultTagName
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    objectId: objectId
    keysPermission: keysPermission
    secretsPermission: secretsPermission
    keyVaultSkuName: keyVaultSkuName
    keyVaultSkuFamily: keyVaultSkuFamily
    keyVaultNameA: keyVaultNameA
    sqlAdminUserName: sqlAdminUserName
    keyVaultNameB: keyVaultNameB
    sqlPassword: sqlPassword
    keyVaultPrivateDnsZoneConfigs: keyVaultPrivateDnsZoneConfigs
    keyVaultPrivateEndpointName: keyVaultPrivateEndpointName
    keyVaultPrivateEndpointTagName: keyVaultPrivateEndpointTagName
    keyVaultPrivateLinkServiceConnectionsName: keyVaultPrivateLinkServiceConnectionsName
    keyVaultGroupId: keyVaultGroupId
    keyVaultDnsZoneLocation: keyVaultDnsZoneLocation
    keyVaultDnsZoneName: keyVaultDnsZoneName
    keyVaultDnsZoneTagName: keyVaultDnsZoneTagName
    keyVaultRegistrationEnabled: keyVaultRegistrationEnabled
    keyVaultVnetLinkLocation: keyVaultVnetLinkLocation
    storageName: storageName
    storageAccountTagName: storageAccountTagName
    storageKind: storageKind
    storageSku: storageSku
    storageAccessTier: storageAccessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    ishnsEnabled: ishnsEnabled
    blobEnabled: blobEnabled
    fileEnabled: fileEnabled
    queueEnabled: queueEnabled
    tableEnabled: tableEnabled
    storageAccountPrivateEndpointName: storageAccountPrivateEndpointName
    storageAccountPrivateEndpointTagName: storageAccountPrivateEndpointTagName
    storageAccountPrivateLinkServiceConnectionsName: storageAccountPrivateLinkServiceConnectionsName
    storageAccountGroupId: storageAccountGroupId
    storageAccountDnsZoneName: storageAccountDnsZoneName
    storageAcccountPrivateDnsZoneConfigs: storageAcccountPrivateDnsZoneConfigs
    storageAccountDnsZoneLocation: storageAccountDnsZoneLocation
    storageAccountDnsZoneTagName: storageAccountDnsZoneTagName
    storageAccountRegistrationEnabled: storageAccountRegistrationEnabled
    storageAccountVnetLinkLocation: storageAccountVnetLinkLocation
    synapseName: synapseName
    synapseTagName: synapseTagName
    sqlAdministratorLogin: keyVault.getSecret(keyVaultNameA)
    sqlAdministratorLoginPassword: keyVault.getSecret(keyVaultNameB)
    storageAccountUrl: storageAccountUrl
    fileSystemName: fileSystemName
    synapsePrivateEndpointName: synapsePrivateEndpointName
    synapsePrivateEndpointTagName: synapsePrivateEndpointTagName
    synapsePrivateLinkServiceConnectionsName: synapsePrivateLinkServiceConnectionsName
    synapseGroupId: synapseGroupId
    synapseDnsZoneName: synapseDnsZoneName
    synapseDnsZoneLocation: synapseDnsZoneLocation
    synapseDnsZoneTagName: synapseDnsZoneTagName
    synapseVnetLinkLocation: synapseVnetLinkLocation
    synapseRegistrationEnabled: synapseRegistrationEnabled
    synapsePrivateDnsZoneConfigs: synapsePrivateDnsZoneConfigs
    synapsePrivateLinkHubDnsZoneLocation: synapsePrivateLinkHubDnsZoneLocation
    synapsePrivateLinkHubDnsZoneName: synapsePrivateLinkHubDnsZoneName
    synapsePrivateLinkHubDnsZoneTagName: synapsePrivateLinkHubDnsZoneTagName
    synapsePrivateLinkHubEndpointName: synapsePrivateLinkHubEndpointName
    synapsePrivateLinkHubEndpointTagName: synapsePrivateLinkHubEndpointTagName
    synapsePrivateLinkHubGroupId: synapsePrivateLinkHubGroupId
    synapsePrivateLinkHubName: synapsePrivateLinkHubName
    synapsePrivateLinkHubPrivateDnsZoneConfigs: synapsePrivateLinkHubPrivateDnsZoneConfigs
    synapsePrivateLinkHubPrivateLinkServiceConnectionsName: synapsePrivateLinkHubPrivateLinkServiceConnectionsName
    synapsePrivateLinkHubRegistrationEnabled: synapsePrivateLinkHubRegistrationEnabled
    synapsePrivateLinkHubTagName: synapsePrivateLinkHubTagName
    synapsePrivateLinkHubVnetLinkLocation: synapsePrivateLinkHubVnetLinkLocation
    dedicatedSqlPoolName: dedicatedSqlPoolName
    dedicatedSqlPoolDnsZoneLocation: dedicatedSqlPoolDnsZoneLocation
    dedicatedSqlPoolDnsZoneName: dedicatedSqlPoolDnsZoneName
    dedicatedSqlPoolDnsZoneTagName: dedicatedSqlPoolDnsZoneTagName
    dedicatedSqlPoolGroupId: dedicatedSqlPoolGroupId
    dedicatedSqlPoolPrivateDnsZoneConfigs: dedicatedSqlPoolPrivateDnsZoneConfigs
    dedicatedSqlPoolPrivateEndpointName: dedicatedSqlPoolPrivateEndpointName
    dedicatedSqlPoolPrivateEndpointTagName: dedicatedSqlPoolPrivateEndpointTagName
    dedicatedSqlPoolPrivateLinkServiceConnectionsName: dedicatedSqlPoolPrivateLinkServiceConnectionsName
    dedicatedSqlPoolRegistrationEnabled: dedicatedSqlPoolRegistrationEnabled
    dedicatedSqlPoolSkuCapacity: dedicatedSqlPoolSkuCapacity
    dedicatedSqlPoolSkuName: dedicatedSqlPoolSkuName
    dedicatedSqlPoolSkuTier: dedicatedSqlPoolSkuTier
    dedicatedSqlPoolTagName: dedicatedSqlPoolTagName
    dedicatedSqlPoolVnetLinkLocation: dedicatedSqlPoolVnetLinkLocation
    apacheSparkPoolName: apacheSparkPoolName
    apacheSparkPoolTagName: apacheSparkPoolTagName
    saprkPoolDynamicExecutorAllocation: saprkPoolDynamicExecutorAllocation
    sparkNodeSize: sparkNodeSize
    sparkPoolAutoPauseEnable: sparkPoolAutoPauseEnable
    sparkPoolAutoScaleEnable: sparkPoolAutoScaleEnable
    sparkPoolDelayInMinutes: sparkPoolDelayInMinutes
    sparkPoolMaxNodeCount: sparkPoolMaxNodeCount
    sparkPoolMinNodeCount: sparkPoolMinNodeCount
    sparkPoolNodeSizeFamily: sparkPoolNodeSizeFamily
    sparkVersion: sparkVersion
  }
}
