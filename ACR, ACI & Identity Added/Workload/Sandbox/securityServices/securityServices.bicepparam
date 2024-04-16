using 'securityServices.main.bicep'

param environment = 'rd' // dev
param domainName = 'ai'
param location = 'eastus2'
param resourceGroupName = 'dev-eu2-ai-monitor-rg'
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
param storageAccountSku = 'Standard_LRS'
param allowPulicAccessFromSelectedNetwork = false
param storageAccessADGroupObjectId = '25015c8a-35ae-4b45-a075-593a9f959ccf'
param workspaceId = '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourcegroups/defaultresourcegroup-eus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-de9f4996-a1cd-4ddc-b28c-7331aa0f0d14-eus2'
param privateZoneDnsID = [
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net'
  '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourceGroups/private-dns-rg/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net'
]
/*param containers = {
  container: [
    {
      name: 'logs'
      blobPublicAccess: 'None'

    }
  ]
}*/
