using 'networkServices.main.bicep'

param environment = 'dev' // dev
param domainName = 'ai'
param location = 'eastus2'
param resourceGroupName = 'dev-eu2-ai-network-rg'
param resourceTags = {
  Environment: 'dev'
  ApplicationName: 'PS Generator'
  BusinessUnit: 'Analytics'
  ApplicationPurpose: 'AI'
  ResourcePurpose: 'AI Core Services'
}
param newOrExisting = 'new'
param existingVnetName = 'dev-eu2-ai-vnet01'
param vnetAddressSpace = [ '10.0.0.0/16' ] // ['10.0.0.0/16','10.0.1.0/16' ]
param subnetAddressPrefix = {
  compute: '10.0.0.0/24'
  data: '10.0.1.0/24'
  app: '10.0.2.0/24'
  apim: '10.0.3.0/24'
}
param enableDiagnosticSetting = true
param workspaceId = '/subscriptions/de9f4996-a1cd-4ddc-b28c-7331aa0f0d14/resourcegroups/defaultresourcegroup-eus2/providers/microsoft.operationalinsights/workspaces/defaultworkspace-de9f4996-a1cd-4ddc-b28c-7331aa0f0d14-eus2'
param routeTableRoutes = [
  {
    name: 'intra_Virtual_Network'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.50.1.36'
      hasBgpOverride: false
    }
  }
]
