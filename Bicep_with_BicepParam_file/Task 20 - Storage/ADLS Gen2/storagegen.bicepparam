using 'storagegen.bicep'

param storageAccountName = 'mynewuniquehemangstorage'
param storageAccountSku = 'Standard_LRS'
param location = 'Central India'
param kind = 'StorageV2'
param accessTier = 'Hot'
param privateEndpointName =  [
  'dfsendpoint'
  'blobendpoint'
  'fileendpoint'
  'tableendpoint'
  'queueendpoint'
]
param vnetName = 'VNET'
param vnetAddressPrefix = '10.0.0.0/16'
param subnetName = 'subnet'
param subnetAddressPrefix = '10.0.0.0/18'
param privateDNSZoneName =  [
  'privatelink.dfs.core.windows.net'
  'privatelink.blob.core.windows.net'
  'privatelink.file.core.windows.net'
  'privatelink.table.core.windows.net'
  'privatelink.queue.core.windows.net'
]
param groupids = [
  'dfs'
  'blob'
  'file'
  'table'
  'queue'
]

param linkservicename = [
  'dfsendpointservice'
  'blobendpointservice'
  'fileendpointservice'
  'tableendpointservice'
  'queueendpointservice'
]
