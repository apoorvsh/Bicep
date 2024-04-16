using 'twowinlin.bicep'

param addressPrefix = [
  '10.0.0.0/16'
  '10.1.0.0/16'
]

param subnet1prefix = [
  '10.0.0.0/18'
  '10.0.64.0/18'
]
param subnet2prefix = [
  '10.1.0.0/18'
  '10.1.64.0/18'
]

param adminPassword = 'Hemang@12345'
param adminUsername = 'winlinvm'
param location = 'Central India '
param OSVersion = '2022-datacenter-azure-edition'
param publicIPAllocationMethod = 'Dynamic'
//param publicIpName = 'myPublicIP'
param publicIpSku = 'Basic'
param securityType = 'Standard'
//param vmName = 'bicepvm'
param vmSize = 'Standard_D2s_v5'
param count = 2
//param publicIpName2 = 'pip2'
