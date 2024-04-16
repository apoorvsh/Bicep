using 'appServices.main.bicep'

param environment = 'rd' //dev
param domainName = 'ai'
param location = 'eastus2'
param resourceGroupName = 'dev-eu2-ai-app-rg'
param resourceTags = {
  Environment: 'dev'
  ApplicationName: 'PS Generator'
  BusinessUnit: 'Analytics'
  ApplicationPurpose: 'AI'
  ResourcePurpose: 'AI Core Services'
}
param networkAccessApproach = 'Private'
param apimRestore = false //'If already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false", "Only API Management services deleted within the last 48 hours can be recovered."'
param allowPulicAccessFromSelectedNetwork = false
param vnetResourceGroupName = 'dev-eu2-ai-network-rg'
param vnetName = 'dev-eu2-ai-vnet01'
param appSubnetName = 'dev-eu2-ai-snet-app01'
param apimSubnetName = 'dev-eu2-ai-snet-apim01'
param pvSubnetName = 'dev-eu2-ai-snet-data01'
param publisherEmail = 'apim@contoso.com'
param publisherName = 'Contoso'
param virtualNetworkType = 'Internal'
param storageAccountSku = 'Standard_LRS'
param storageAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param apimAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param funAppAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param privateZoneDnsID = [
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net'
]
param appServiceOsVersion = 'Linux'
param appServiceSkuVersion = 'PremiumV2'
param enableDiagnosticSetting = true
param workspaceId = '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourcegroups/defaultresourcegroup-eus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-de9f4996-a1cd-4ddc-b28c-7331aa0f0d14-eus2'
param storageAccountResourceId = '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/dev-eu2-ai-monitor-rg/providers/Microsoft.Storage/storageAccounts/rdeu2ailogstr01'
