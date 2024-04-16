// Global parameters
@description('Combine Resources Tags')
param resourceTags object
@description('Resource Location')
param location string
@description('Key Vault Name')
param keyVaultName string
@description('Allow Enable Rbac Authorization')
param enableRbacAuthorization bool
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Allow Enable Purge Protection')
param enablePurgeProtection bool
@description('Allow Enable Soft Delete')
param enableSoftDelete bool = false
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool = false

@description('Key Vault Sku')
var keyVaultSku = 'standard'
@description('Key Vault Family')
var keyVaultFamily = 'A'
@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
var tenantId = subscription().tenantId
@description('Allow Enabled For Deployment ')
var enabledForDeployment = true
@description('Allow Enabled For Disk Encryption')
var enabledForDiskEncryption = true
@description('Allow Enabled For Template Deployment')
var enabledForTemplateDeployment = true
@description('Key Vault Network access')
var publicNetworkAccess = networkAccessApproach == 'Private' && allowPulicAccessFromSelectedNetwork == bool(false) ? 'Disabled' : 'Enabled'

// creation of azure key vault
resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: resourceTags
  properties: {
    sku: {
      name: keyVaultSku
      family: keyVaultFamily
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection != null && enablePurgeProtection == true ? true : null
    enableRbacAuthorization: enableRbacAuthorization != null && enableRbacAuthorization == true ? true : false
    enableSoftDelete: enableSoftDelete != null && enableSoftDelete == true ? true : false
    tenantId: tenantId
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: allowPulicAccessFromSelectedNetwork == bool(true) ? 'Deny' : 'Allow'
    }
    accessPolicies: []
  }
}

// output key vault used in accessPolicies.bicep to add access policy in existing key vault
output keyVaultName string = keyvault.name
output keyVaultId string = keyvault.id
