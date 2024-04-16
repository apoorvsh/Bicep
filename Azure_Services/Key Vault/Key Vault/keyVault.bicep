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
@description('User Name for login into Virtual Machine')
@secure()
param vmUserName string
@description('Password for login into Virtual Machine')
@secure()
param vmPassword string
@description('User Name for login into SQL database, Dedicated SQL Pool')
@secure()
param sqlUserName string
@description('Password for login into SQL database, Dedicated SQL Pool ')
@secure()
param sqlPassword string
@description('Existing Key Vault Private DNS Zone')
param existingKeyVaultPrivateDnsZoneId string
@description('Vnet Address Space')
param vnetAddressSpace string
@description('subnet address Prefix')
param subnetAddressPrefix string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool

// variables
@description('Virtual Network Name')
var newVnetName = toLower('vnet-${projectCode}-${environment}-network01')
@description('Private Endpoint Subnet Name')
var subnetName = toLower('sub-${projectCode}-${environment}-pv01')
@description('Key Vault Name')
var keyVaultName = toLower('kv${projectCode}${environment}secret09f')
@description('Key Vault Sku')
var keyVaultSku = 'standard'
@description('Key Vault Family')
var keyVaultFamily = 'A'
@description('Key Vault Private Endpoint Name')
var keyVaultPrivateEndpointName = toLower('pep-${projectCode}-${environment}-kv01')
@description('Network Interface Name for Key Vault Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}kv01')
@description('Target Sub Resource of Key Vault')
var groupId = 'vault'
@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId
@description('Allow Enabled For Deployment ')
var enabledForDeployment = true
@description('Allow Enabled For Disk Encryption')
var enabledForDiskEncryption = true
@description('Allow Enabled For Template Deployment')
var enabledForTemplateDeployment = true
@description('Allow Enable Purge Protection')
var enablePurgeProtection = true
@description('Allow Enable Rbac Authorization')
var enableRbacAuthorization = false
@description('Allow Enable Soft Delete')
var enableSoftDelete = true
@description('Key Vault Network access')
var publicNetworkAccess = networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(false) ? 'Disabled' : 'Enabled'
var secrets = [
  {
    name: 'vmUserName'
    secretValue: vmUserName
  }
  {
    name: 'vmPassword'
    secretValue: vmPassword
  }
  {
    name: 'sqlUserName'
    secretValue: sqlUserName
  }
  {
    name: 'sqlPassword'
    secretValue: sqlPassword
  }
]
var kvPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var kvPvtEndpointDnsGroupName = '${keyVaultPrivateEndpointName}/mydnsgroupname'
var networkAcls = {
  defaultAction: 'Deny'
  bypass: 'AzureServices'
  virtualNetworkRules: [
    {
      id: subnet.id
      action: 'Allow'
    }
  ]
  ipRules: []
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: newVnetName
  location: location
  tags: union({
      Name: newVnetName
    }, combineResourceTags)
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
  }
}

// creation of subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddressPrefix
    serviceEndpoints: [
      {
        service: 'Microsoft.KeyVault'
      }
    ]
  }
}

// creation of azure key vault
resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: union({
      Name: keyVaultName
    }, combineResourceTags)
  properties: {
    sku: {
      name: keyVaultSku
      family: keyVaultFamily
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    tenantId: tenantId
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(true) ? networkAcls : null
    accessPolicies: []
  }
}

// creating Secrets inside Azure Key Vault
resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [for (config, i) in secrets: {
  name: config.name
  parent: keyvault
  properties: {
    value: config.secretValue
  }
}]

// creation of key vault private endpoint
resource kvPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: keyVaultPrivateEndpointName
  location: location
  tags: union({
      Name: keyVaultPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateEndpointName
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: customNetworkInterfaceName
    subnet: {
      id: subnet.id
    }
  }
}

resource kvPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: kvPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: kvPrivateDnsZoneName
    }, combineResourceTags)
}

resource kvPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: kvPrivateDnsZone
  name: '${virtualNetwork.name}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource kvPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: kvPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? kvPrivateDnsZone.id : existingKeyVaultPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    kvPrivateEndpoint
  ]
}

// output key vault used in accessPolicies.bicep to add access policy in existing key vault
output keyVaultName string = keyvault.name
