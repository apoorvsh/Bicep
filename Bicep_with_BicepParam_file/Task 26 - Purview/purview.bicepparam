using 'purview.bicep'

param purviewAccountName = 'hemangPurview'

param managedResourceGroupName = 'trymanaged'

param vnetName = 'Vnet'

param vnetAddressPrefix = [
  '10.0.0.0/16'
]

param subnetName = 'Subnet'

param subnetAddressPrefix = '10.0.0.0/18'

param location = 'Central India'

param purviewEndpointName = [
  'perviewPvtEnd'
  'perviewStudioPvtEnd'
  'ingestionqueue'
  'perviewingestion'
  'EventHubEndPoint'
] 

param privateDNSZoneName = [
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.queue.core.windows.net'
  'valueprivatelink.servicebus.windows.net'
]

param groupIDs = [
  'account'
  'portal'
  'blob'
  'queue'
  'namespace'
]
