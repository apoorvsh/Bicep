using 'aiServices.main.bicep'

param environment = 'rd' //dev
param domainName = 'ai'
param location = 'eastus2'
param resourceGroupName = 'dev-eu2-ai-aiservices-rg'
param resourceTags = {
  Environment: 'dev'
  ApplicationName: 'PS Generator'
  BusinessUnit: 'Analytics'
  ApplicationPurpose: 'AI'
  ResourcePurpose: 'AI Core Services'
}
param cognitiveServiceRestore = true //Cognitive Service is already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false"'
param enableDiagnosticSetting = true
param networkAccessApproach = 'Private'
param vnetResourceGroupName = 'dev-eu2-ai-network-rg'
param vnetName = 'dev-eu2-ai-vnet01'
param pvSubnetName = 'dev-eu2-ai-snet-data01'
param aiCognitiveServiceAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param openAiAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param workspaceId = '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourcegroups/defaultresourcegroup-eus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-de9f4996-a1cd-4ddc-b28c-7331aa0f0d14-eus2'
param storageAccountResourceId = '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/dev-eu2-ai-monitor-rg/providers/Microsoft.Storage/storageAccounts/rdeu2ailogstr01'
param privateZoneDnsID = [
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourcegroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com'
]
