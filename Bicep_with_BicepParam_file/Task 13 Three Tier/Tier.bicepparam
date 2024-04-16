using 'Tier.bicep'

param addressPrefix = '10.0.0.0/16'
param adminPassword = 'Hemang@12345'
param adminUsername = 'Tier'
param count = 3
param location = 'Central India'
param nicname = [
  'webnic'
  'appnic'
  'dbnic'
]
param OSVersion = '2022-datacenter-azure-edition'
param securityType = 'Standard'
param subnetname = [
  'websubnet'
  'appsubnet'
  'dbsubnet'
]
param subnetprefix = [
  '10.0.0.0/18'
  '10.0.64.0/18'
  '10.0.128.0/18'
]
param vmname = [
  'webvm'
  'appvm'
  'dbvm'
]

param vmSize = 'Standard_B1s'
param vnetname = 'vnet'
param publicIPAllocationMethod = 'Dynamic'
param publicIpSku = 'Basic'
