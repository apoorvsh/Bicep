using './synapsepoint.bicep'

param location = 'centralindia'
param privateEndpointName = [
  'PvtEndSql'
  'PvtEndSqlOnDemand'
  'PvtEndDev'
]
param vnetName = 'VNET'
param vnetAddressPrefix = '10.0.0.0/16'
param subnetName = 'subnet'
param subnetAddressPrefix = '10.0.0.0/18'
param privateDNSZoneName = [
  'privatelink.sql.azuresynapse.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.sqlDemand.azuresynapse.net'
]
param groupids = [
  'sql'
  'sqlOnDemand'
  'dev'
]
param linkservicename = [
  'sqllink'
  'sqldemandlink'
  'devlink'
]
param workspaceName = 'privatespace'
param sqlAdministratorLogin = 'sqladminuser'
param sqlAdministratorLoginPassword = 'Hemang@12345'
param saName = 'hemangctstorage'
param loganalyticsworkspaceName = 'hemangworklogs'
