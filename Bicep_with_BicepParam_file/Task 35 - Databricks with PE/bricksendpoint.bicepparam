using './bricksendpoint.bicep'

param databricksname = 'hemangbrick'
param networkaccess = 'Disabled'
param nsgrules = 'NoAzureDatabricksRules'
param managedrgname = 'mrghemang'
param subnetname = [
  'endpoint-subnet'
  'public-subnet'
  'private-subnet'
]
param subnetprefix = [
  '10.0.0.0/18'
  '10.0.64.0/18'
  '10.0.128.0/18'
]
param vnetname = 'VNET'
param location = 'centralindia'
param addressprefix = '10.0.0.0/16'
param count = 3
param nsgName = 'nsg'
param nsgLocation = 'centralindia'
param delegationname = [
  'publicdelegation'
  'privatedelegation'
]
param privateEndpointName = 'brickendpoint'
param privateDNSZoneName = 'privatelink.azuredatabricks.net'
param groupID = 'databricks_ui_api'
param tier = 'premium'
param publicIP = true
