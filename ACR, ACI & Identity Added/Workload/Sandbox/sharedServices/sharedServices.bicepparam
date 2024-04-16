using 'sharedServices.main.bicep'

param environment = 'ct' // dev
param domainName = 'ai'
param location = 'eastus2'
param resourceGroupName = 'dev-eu2-ai-shared-rg'
param resourceTags = {
  Environment: 'dev'
  ApplicationName: 'PS Generator'
  BusinessUnit: 'Analytics'
  ApplicationPurpose: 'AI'
  ResourcePurpose: 'AI Core Services'
}
param enableDiagnosticSetting = true
param enableSoftDelete = true
param enablePurgeProtection = true
param enableRbacAuthorization = true
param allowPulicAccessFromSelectedNetwork = false
param networkAccessApproach = 'Private'
param adfAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param kvAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param vnetResourceGroupName = 'dev-eu2-ai-network-rg'
param vnetName = 'dev-eu2-ai-vnet01'
param pvSubnetName = 'dev-eu2-ai-snet-data01'
param availabilityOption = 'null' // Availability_Set or Availability_Zone or null
param computeSubnetName = 'dev-eu2-ai-snet-compute01'
param virtualMachineType = 'windows' // linux 
param vmPassword = getSecret('exampleSubscription', 'exampleResourceGroup', 'exampleKeyVault', 'exampleSecretUserName', 'exampleSecretVersion') //getSecret('exampleSubscription', 'exampleResourceGroup', 'exampleKeyVault', 'exampleSecretUserName', 'exampleSecretVersion')
param vmUserName = getSecret('exampleSubscription', 'exampleResourceGroup', 'exampleKeyVault', 'exampleSecretUserName', 'exampleSecretVersion') //az.getSecret('exampleSubscription', 'exampleResourceGroup', 'exampleKeyVault', 'exampleSecretUserName', 'exampleSecretVersion')
param storageAccountName = 'cteu2ailogstr01' // Required for Virtual Machine Diagnostic Settings that was created during security services
param workspaceId = '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourcegroups/dev-eu2-ai-monitor-rg/providers/microsoft.operationalinsights/workspaces/ct-eu2-ai-log-01'
param storageAccountResourceId = '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourceGroups/dev-eu2-ai-monitor-rg/providers/Microsoft.Storage/storageAccounts/cteu2ailogstr01'
param privateZoneDnsID = [
  '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourceGroups/hub-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
  '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourcegroups/hub-rg/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.net'
]
