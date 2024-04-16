targetScope = 'subscription'

@description('Location for the all the Azure Services')
param location string = deployment().location
@description('Tags for the resoruces')
param resourceTags object
@description('Resource Group Name')
param resourceGroupName string
param environment string
param domainName string
@description('Network Access Public or Private')
@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param pvSubnetName string
@description('Private DNS Zone IDS')
param privateZoneDnsID array
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Resource Id of the workspace that will have the Azure Activity log sent to')
param workspaceId string
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''
@description('Secrets inside Key Vault')
@secure()
param secrets object = {}
@description('Azure AD Group Object ID is required to manage keys, secrets, cerficate inside Key Vault')
param kvAccessADGroupObjectId string
@description('Allow Enable Purge Protection')
param enablePurgeProtection bool
@description('Allow Enable Rbac Authorization')
param enableRbacAuthorization bool
@description('Allow Enable Soft Delete')
param enableSoftDelete bool = true
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool = true

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}
var resourceNames = {
  keyVaultName: take(toLower('${environment}-${locationMap[location]}-${domain}-core-kv01'), 24)
  privateEndpointName: [
    toLower('${environment}-${locationMap[location]}-${domain}-pv-vault01')
  ]
  privateEndpointNicNames: [
    toLower('${environment}${locationMap[location]}${domain}nicvault01')
  ]
}
var groupIds = [
  'vault'
]
var resouceID = [for groupId in groupIds: existing_Key_Vault.id]

resource existing_Key_Vault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: resourceNames.keyVaultName
  scope: resourceGroup(resourceGroup_Creation.name)
}

module resourceGroup_Creation '../../../Modules/Resource Group/resource_group.mod.bicep' = {
  name: resourceGroupName
  params: {
    location: location
    name: resourceGroupName
    resourceTags: resourceTags
  }
}

module key_Vault '../../../Modules/Key Vault/key_vault.mod.bicep' = {
  name: 'deploy-keyVault'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    keyVaultName: resourceNames.keyVaultName
    resourceTags: resourceTags
    location: location
    enablePurgeProtection: enablePurgeProtection
    networkAccessApproach: networkAccessApproach
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
  }
}

module kv_Access_Policy '../../../Modules/Key Vault/accessPolicies.mod.bicep' = if (enableRbacAuthorization != true) {
  name: 'deploy-kvAccessPolicies'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    keyVaultName: resourceNames.keyVaultName
    kvAccessADGroupObjectId: kvAccessADGroupObjectId
  }
  dependsOn: [
    key_Vault
  ]
}

module keyVault_Secrets '../../../Modules/Key Vault/secrets.mod.bicep' = if (contains(secrets, 'secret') && !empty(secrets)) {
  name: 'deploy-kvSecrets'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    keyVaultName: resourceNames.keyVaultName
    secrets_cfg: secrets
  }
  dependsOn: [
    key_Vault
  ]
}

module kv_Admin_Role '../../../Modules/Key Vault/key_vault_admin_roleassign.mod.bicep' = if (enableRbacAuthorization != false) {
  name: 'deploy-kvAdministrator-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    keyVaultName: resourceNames.keyVaultName
    kvAccessADGroupObjectId: kvAccessADGroupObjectId
  }
  dependsOn: [
    key_Vault
  ]
}

module keyVault_Diagnostic '../../../Modules/Key Vault/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-keyVault-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    keyVaultName: resourceNames.keyVaultName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    key_Vault
  ]
}

module private_Endpoint '../../../Modules/Network/private_endpoint.mod.bicep' = if (networkAccessApproach != 'Public') {
  name: 'deploy-privateEndpoint'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    privateEndpointName: resourceNames.privateEndpointName
    privateEndpointNicNames: resourceNames.privateEndpointNicNames
    location: location
    resourceTags: resourceTags
    vnetResourceGroupName: vnetResourceGroupName
    vnetName: vnetName
    pvSubnetName: pvSubnetName
    groupIDs: groupIds
    resourceID: resouceID
  }
  dependsOn: [
    key_Vault
  ]
}

module private_Dns_Zone_Group '../../../Modules/Network/private_dns_zone_group.mod.bicep' = if (networkAccessApproach != 'Public') {
  name: 'deploy-privateDnsZoneGroup'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    privateEndpointName: resourceNames.privateEndpointName
    privateDnsZoneID: privateZoneDnsID
  }
  dependsOn: [
    private_Endpoint
  ]
}
