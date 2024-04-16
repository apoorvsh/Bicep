using 'coreServices.main.bicep'

param environment = 'ct' //dev
param domainName = 'ai'
param location = 'eastus2'
param resourceGroupName = 'dev-eu2-ai-core-identity-rg'
param resourceTags = {
  Environment: 'dev'
  ApplicationName: 'PS Generator'
  BusinessUnit: 'Analytics'
  ApplicationPurpose: 'AI'
  ResourcePurpose: 'AI Core Services'
}
param vnetResourceGroupName = 'dev-eu2-ai-network-rg'
param vnetName = 'dev-eu2-ai-vnet01'
param pvSubnetName = 'dev-eu2-ai-snet-data01'
param enableDiagnosticSetting = true
param networkAccessApproach = 'Private'
param enablePurgeProtection = true
param enableSoftDelete = true
param enableRbacAuthorization = false
param allowPulicAccessFromSelectedNetwork = true
param kvAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param workspaceId = '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourcegroups/dev-eu2-ai-monitor-rg/providers/microsoft.operationalinsights/workspaces/ct-eu2-ai-log-01'
param storageAccountResourceId = '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourceGroups/dev-eu2-ai-monitor-rg/providers/Microsoft.Storage/storageAccounts/cte2aist01'
param privateZoneDnsID = [
  '/subscriptions/b5533628-3487-4c82-82e0-d8a1ec636707/resourceGroups/hub-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
]
param secrets = {
  secret: [
    {
      name: 'username'
      value: 'testuser'
    }
    {
      name: 'password'
      value: 'password@123'
    }
  ]
}
