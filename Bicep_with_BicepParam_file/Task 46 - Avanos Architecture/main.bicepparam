using './main.bicep'













param values = {
  rgNames: [
    'DevRG'
    'HubRG'
  ]
  name: 'devVnet'
  hubVnetName: 'hubVnet'
  
  location : 'eastus'
  hublocation: 'centralindia'

  addressprefix: '10.0.0.0/16'
  

   count: 3

   subnetname: [
    'endpointsubnet'
    'delesubnet'
    'vmsubnet'
   ]
   subnetprefix: [
   '10.0.0.0/18'
   '10.0.64.0/18'
   '10.0.128.0/18'
  ]

   hubModuleName :'hubModule'
   vngSubnetName : 'GatewaySubnet'
   vngAddressPrefix : '10.1.0.0/16'
   vngSubnetPrefix : '10.1.0.0/18'
   nsgName :  'devNsg'
   delegationName : 'powerplatform-del-public'
   serviceName : 'Microsoft.powerplatform/vnetaccesslinks'
   vnetSubModuleName: 'vnetSubModule'
   nsgModule :'nsgModule'
   publicIPAllocationMethod: 'static'
   publicIpName: [
     'publicIpDev'
     'publicIpHub'
   ]
   hubToDevModule: 'hubToDev'
   devToHubModule: 'devToHub'
   publicIpSku: 'Standard'
   publicModuleName : 'publicIpModule'
   hubpublicIpModuleName: 'hubPublicIpModule'
   publicIpCount: 2
   adminPassword: 'Hemang@12345'
   adminUsername :'hemangadmin'
   vmName :'vm'
   vmSize :'Standard_D2s_v5'
   publisher: 'MicrosoftWindowsServer'
   OSVersion :'2022-datacenter-azure-edition'
   securityType :'Standard' 
   vmModule :'vmModule'
   nicName: 'nic'
   nicModule: 'nicModule'
   endpointCount :6
   endpointModuleName :'endpointModule'
   adfName: 'factorydev44'
   keyVaultName: 'vaultdev448'
   storageName: 'storagedev448'
   workSpaceName: 'workdevspace448'
   groupIds :[
   'dataFactory'
   'vault'
   'blob'
   'dfs'
   'sql'
   'Dev'
  ]
  linkServiceName :[
   'dataFactoryLink'
   'vaultLink'
   'blobLink'
   'adlsLink'
   'sqlLink'
   'devLink'
  ]

 nicInterfaceName :[
  'dataFactoryNIC'
  'vaultNIC'
  'blobNIC'
  'adlsNIC'
  'sqlNIC'
  'devNIC'
 ]

 privateDNSZoneGroupName :[
  'dataFactoryPrivateDnsGroup'
  'vaultPrivateDnsGroup'
  'blobPrivateDnsGroup'
  'adlsPrivateDnsGroup'
  'synapsePrivateDnsGroup'
  'synapseDevPrivateDnsGroup'

 ]

 privateEndpointName :[
  'adfEndpoint'
  'vaultEndpoint'
  'blobEndpoint'
  'adlsEndpoint'
  'synapseEndpoint'
  'synapseDevEndpoint'
 ]

 privateDnsZoneLinkName :[
  'adfDnsLink'
  'vaultDnsLink'
  'blobDnsLink'
  'adlsDnsLink'
  'synapseDnsLink'
  'synapseDevLink'
  'extraLink'
 ]

 privateDNSZoneName :[
  'privatelink.datafactory.azure.net'
  'privatelink.vaultcore.azure.net'
  'privatelink.blob.core.windows.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.sql.azuresynapse.net'
  'privatelink.dev.azuresynapse.net'
 ]
  dnsCount :6 
  linkCount :7
  hubDNSZoneModuleName: 'hubDNS'
  adfModulename :'adfModule'
  type :'SystemAssigned'
  networkAccess :'Disabled'
  accessTier :'Hot'
  adlsModuleName :'adlsModule'
  kind :'StorageV2'
  storageAccountSku :'Standard_LRS'
  enabledForDeployment :true
  enabledForDiskEncryption :false
  enabledForTemplateDeployment :true
  enableRbacAuthorization :false
  enableSoftDelete :true
  objectID :'3e98f5f4-3e7a-48bc-86cd-ac615efa40ce'
  publicNetworkAccess :'Enabled'
 
  secrets :[
  'Get' 
  'List' 
  'Set' 
  'Delete'
  'Recover' 
  'Backup' 
  'Restore'
 ]
 softDeleteRetentionInDays :90
 vaultModuleName :'vaultModule'
 sqlAdministratorLogin :'sqladminuser'

 

  synapseModuleName :'synapseModule'
  sqlAdministratorLoginPassword: 'Hemang@12345'
  saName :'hemangctstorage'
  
  vngname :'hemangvng'
  disable :false
  gatewaytype :'Vpn'
  tier :'VpnGw2AZ'
  vpntype :'RouteBased'
  generation :'Generation2'
  vngmodulename :'vngModule'
}




















//param dnsZoneModuleName = 'dnsZoneModule'

















