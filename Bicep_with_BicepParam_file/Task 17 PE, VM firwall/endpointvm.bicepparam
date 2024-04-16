using 'endpointvm.bicep'

param keyVaultName = 'givesomerandomnameauto'
param location = 'Central India'
param objectID = '1c5cb538-bb0c-4852-afb2-e978ab23c98c'
param secrets =  [
  'Get' 
  'List' 
  'Set' 
  'Delete'
  'Recover' 
  'Backup' 
  'Restore'
]
param enabledForDeployment = true
param enabledForTemplateDeployment = true
param enabledForDiskEncryption = false
param enableRbacAuthorization = false
param enableSoftDelete = true
param softDeleteRetentionInDays = 90
param publicNetworkAccess = 'Enabled'
param secretName = 'key'
@secure()
param secretValue = 'hemang@12345'
param privateEndpointName = 'myendpoint'
param vnetName = 'VNET'
param vnetAddressPrefix = '10.0.0.0/16'
param subnetName = 'subnet'
param subnetAddressPrefix = '10.0.0.0/18'
param privateDNSZoneName = 'privatelink.vaultcore.azure.net'
