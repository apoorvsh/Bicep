using './main.bicep'

param values = {
  rgNames: 'taskRG'
  location: 'centralindia'

  count: 6

  name: 'vnet'
  addressprefix: '10.0.0.0/16'
  subnetname: [
    'subnet1'
    'subnet2'
  ]
  subnetprefix:  [
    '10.0.0.0/18'
    '10.0.64.0/18'
  ]
  subnetCount: 2

  nsgName: 'nsg'

  adfModuleName: 'adfmodule'
  storageModuleName: 'storageModule'
  nsgModuleName: 'nsgModule'
  dnsModuleName: 'dnsModule'
  endpointsModuleName: 'endpointsModule'
  vnetModuleName: 'vnetModule'

  roleDefinitionResourceId: '/providers/Microsoft.Authorization/roleDefinitions/673868aa-7521-48a0-acc6-0f60742d39f5'
  storageRoleDefinitionResourceId: '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  principalId: 'f5e62754-b4a1-4bfe-a86c-6c19799f0ebb'
  storagePrincipalID: '4f4984aa-72ea-45b9-b964-91469c9ec96d'

  adfName: 'hemangFactory'
  type: 'SystemAssigned'
  networkAccess: 'Disabled'

  storageName: 'hemangstorage48'
  storageAccountSku: 'Standard_LRS'
  kind: 'StorageV2'
  accessTier: 'Hot'

  privateDNSZoneName: [
    'privatelink.datafactory.azure.net'
    'privatelink.dfs.core.windows.net'
    'privatelink.blob.core.windows.net'
    'privatelink.file.core.windows.net'
    'privatelink.queue.core.windows.net'
    'privatelink.table.core.windows.net'
  ]
  privateDnsZoneLinkName: [
    'adfDnsLink'
    'adlsDnsLink'
    'blobDnsLink'
    'fileDnsLink'
    'queueDnsLink'
    'tableDevLink'
  ]

  privateEndpointName: [
    'adfendpoint'
    'adlsendpoint'
    'blobendpoint'
    'fileendpoint'
    'queueendpoint'
    'tableendpoint'
  ]
  linkServiceName: [
    'adfLink'
    'adfsLink'
    'blobLink'
    'fileLink'
    'queueLink'
    'tableLink'
  ]
  groupIds: [
    'dataFactory'
    'dfs'
    'blob'
    'file'
    'queue'
    'table'
  ]  
  nicInterfaceName: [
    'adfNIC'
    'adlsNIC'
    'blobNIC'
    'fileNIC'
    'queueNIC'
    'tableNIC'
  ]
  privateDNSZoneGroupName: [
    'dataFactoryGroup'
    'dfsGroup'
    'blobGroup'
    'fileGroup'
    'queueGroup'
    'tableGroup'
  ]
  
}
