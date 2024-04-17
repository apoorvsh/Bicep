using './mlstudio.main.bicep'

param resourceTags = {
  Environment: 'dev'
  ApplicationName: 'PS Generator'
  BusinessUnit: 'Analytics'
  Owner: 'SpyGlass_offshore_CT'
  ApplicationPurpose: 'AI'
  Description: 'AI Core Services'
  ExpectedLifetime: '01/01/2024'
}
param kind = 'Default'
param sku = 'Basic'
param location = 'eastus2'
param tier = 'Premium'
param resourceGroupName = 'test-rg'
param identityType = 'systemAssigned'
param primaryUserAssignedIdentityResourceGroup = ''
param containerRegistryFirewallIPEnable = 'Yes'
param primaryUserAssignedIdentityName = ''
param storageAccountOption = 'new'
param storageAccountSku = 'Standard_LRS'
param allowPulicAccessFromSelectedNetwork = false
param networkAccessApproach = 'Private'
param storageAccountResourceGroupName = 'test-rg'
param enableDiagnosticSetting = false
param isHnsEnabled = false
param keyVaultOption = 'new'
param enablePurgeProtection = false
param enableSoftDelete = true
param keyVaultResourceGroupName = 'test-rg'
param applicationInsightsOption = 'new'
param applicationInsightsResourceGroupName = 'test-rg'
param applicationInsightsLogWorkspaceOption = 'new'
param containerRegistryOption = 'new'
param containerRegistrySku = 'Premium'
param containerRegistryResourceGroupName = 'test-rg'
param publicNetworkAccess = 'Disabled'
param applicationInsightsLogWorkspaceResourceGroupName = 'test-rg'
param domainName = 'ai'
param environment = 'dev'
param pvSubnetName = 'default'
param vnetName = 'test-vnet'
param vnetResourceGroupName = 'test-rg'
param privateZoneDnsID = [
  '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourceGroups/privatedns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.api.azureml.ms'
  '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourceGroups/privatedns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.notebooks.azure.net'
]
param mlStudioManagedNetworkMode = 'AllowOnlyApprovedOutbound'
