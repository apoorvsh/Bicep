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
@description('Azure Virual should be part of Availability Zone or Availability set')
@allowed([
  'Availability_Zone'
  'Availability_Set'
  'null'
])
param availabilityOption string = 'null'
@description('Create Windows or Linux Virtual Machine as per the user choice')
@allowed([
  'windows'
  'linux'
])
param virtualMachineType string
@description('User Name for login into VM')
@secure()
param vmUserName string
@description('Password for login into VM')
@secure()
param vmPassword string
@description('Compute Endpoint Subnet Name')
param computeSubnetName string
@description('Azure AD Group Object ID is required to manage keys, secrets, cerficate inside Key Vault')
param kvAccessADGroupObjectId string
@description('Allow Enable Purge Protection')
param enablePurgeProtection bool
@description('Allow Enable Soft Delete')
param enableSoftDelete bool = true
@description('Allow Enable Rbac Authorization')
param enableRbacAuthorization bool
@description('Resource Name of the storage account that will have the Azure Activity log sent to')
param storageAccountName string = ''
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool = false
@description('Create and manage data factories, as well as child resources within them.')
param adfAccessADGroupObjectId string

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}
var resourceNames = {
  keyVaultName: take(toLower('${environment}-${locationMap[location]}-${domain}-kv01'), 24)
  publicIpName: toLower('${environment}-${locationMap[location]}-${domain}-pip01')
  availabilitySetName: toLower('${environment}-${locationMap[location]}-${domain}-avs01')
  virtualMachineName: toLower('${environment}-${locationMap[location]}-${domain}-vm01')
  virtualMachineNicName: toLower('${environment}${locationMap[location]}${domain}vmnic01')
  virtualMachineOsDiskName: toLower('${environment}-${locationMap[location]}-${domain}-Disk01')
  adfName: toLower('${environment}-${locationMap[location]}-${domain}-df01')
  shirName: toLower('${environment}-${locationMap[location]}-${domain}-dfshir01')
  privateEndpointName: [
    toLower('${environment}-${locationMap[location]}-${domain}-pv-vault02')
    toLower('${environment}-${locationMap[location]}-${domain}-pv-df01')
  ]
  privateEndpointNicNames: [
    toLower('${environment}${locationMap[location]}${domain}nicvault02')
    toLower('${environment}${locationMap[location]}${domain}nicdf01')
  ]
}
var groupIds = [
  'vault'
  'dataFactory'
]

//var resouceID = [for groupID in groupIds: contains(groupIds, 'vault') && groupIds == 'vault' ? existingKeyVault.id : contains(groupIds, 'dataFactory') && groupIds == 'dataFactory' ? existingDataFactory.id : existingStorage.id]
var resouceID = [for groupID in groupIds: contains(groupID, 'vault') && groupID == 'vault' ? existing_Key_Vault.id : existing_Data_Factory.id]

resource existing_Key_Vault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: resourceNames.keyVaultName
  scope: resourceGroup(resourceGroup_Creation.name)
}

resource existing_Data_Factory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: resourceNames.adfName
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

module public_IP '../../../Modules/Network/public_IP.mod.bicep' = if (networkAccessApproach != 'Private') {
  name: 'deploy-publicIP'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.publicIpName
    location: location
    resourceTags: resourceTags
  }
}

module pulic_IP_Diagnostic '../../../Modules/Network/diagnostic.mod.bicep' = if (networkAccessApproach != 'Private' && (enableDiagnosticSetting)) {
  name: 'deploy-publicIP-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
    publicIpName: resourceNames.publicIpName
  }
  dependsOn: [
    public_IP
  ]
}

module availability_Set '../../../Modules/Compute/availability_set.mod.bicep' = if (contains(availabilityOption, 'Availability_Set')) {
  name: 'deploy-availablitySet'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.availabilitySetName
    location: location
    resourceTags: resourceTags
  }
}

module virtual_Machine '../../../Modules/Compute/virtual_machine.mod.bicep' = {
  name: 'deploy-virtualMachine'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    vmName: resourceNames.virtualMachineName
    nicName: resourceNames.virtualMachineNicName
    vmOsDiskName: resourceNames.virtualMachineOsDiskName
    location: location
    resourceTags: resourceTags
    virtualMachineType: virtualMachineType
    availabilityOption: availabilityOption
    availabilitySetRef: contains(availabilityOption, 'Availability_Set') ? availability_Set.outputs.availabilitySetId : ''
    publicIPRef: contains(networkAccessApproach, 'Public') ? public_IP.outputs.publicIpID : ''
    vnetName: vnetName
    vnetResourceGroupName: vnetResourceGroupName
    computeSubnetName: computeSubnetName
    vmUserName: vmUserName
    vmPassword: vmPassword
    storageAccountName: storageAccountName
    enableDiagnosticSetting: enableDiagnosticSetting
  }
  dependsOn: [
    public_IP, availability_Set
  ]
}

module vm_Run_command '../../../Modules/Compute/run_command.mod.bicep' = if (contains(virtualMachineType, 'windows')) {
  name: 'deploy-runCommand'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    location: location
    existingVmName: resourceNames.virtualMachineName
  }
  dependsOn: [
    virtual_Machine
  ]
}

module virtual_Machine_Diagnostic '../../../Modules/Compute/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-virtualMachine-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.virtualMachineName
    location: location
    resourceTags: resourceTags
    existingdiagnosticsStorageAccountName: storageAccountName
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    virtual_Machine
  ]
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

module kv_Access_Policy '../../../Modules/Key Vault/accessPolicies.mod.bicep' = if (enableRbacAuthorization != true) {
  name: 'deploy-kvAccessPolicies'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    keyVaultName: resourceNames.keyVaultName
    kvAccessADGroupObjectId: kvAccessADGroupObjectId
    adfObjectId: data_Factory.outputs.adfIdentityPrincipalId
  }
  dependsOn: [
    key_Vault, data_Factory
  ]
}

module adf_Kv_Secret_User_Role '../../../Modules/Data Factory/dataFactory_kv_secret_user_roleassign.mob.bicep' = if (enableRbacAuthorization != false) {
  name: 'deploy-adf-kvSecretUser-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    keyVaultName: resourceNames.keyVaultName
    adfPrincipalID: data_Factory.outputs.adfIdentityPrincipalId
  }
  dependsOn: [
    data_Factory, key_Vault
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

module data_Factory '../../../Modules/Data Factory/dataFactory.bicep' = {
  name: 'deploy-dataFactory'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    adfName: resourceNames.adfName
    location: location
    resourceTags: resourceTags
    networkAccessApproach: networkAccessApproach
    shirName: resourceNames.shirName
  }
}

module adf_Contributor_Role '../../../Modules/Data Factory/data_factory_contributor_role.mod.bicep' = {
  name: 'deploy-adfContributor-role'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.adfName
    adfAccessADGroupObjectId: adfAccessADGroupObjectId
  }
  dependsOn: [
    data_Factory
  ]
}

module dataFactory_Diagnostic '../../../Modules/Data Factory/diagnostic.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-dataFactory-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    dataFactoryName: resourceNames.adfName
    workspaceId: workspaceId
    storageAccountResourceId: storageAccountResourceId
  }
  dependsOn: [
    data_Factory
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
    key_Vault, data_Factory
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
