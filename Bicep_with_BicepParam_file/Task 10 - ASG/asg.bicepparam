using 'asg.bicep'

param addressPrefix = [
  '10.0.0.0/16'
  '10.1.0.0/16'
]

param adminPassword = 'Hemang@12345'
param adminUsername = 'asgvms'
param count = 2
param location = 'Central India'
param niccount = 8
param nSGName = 'nsg'
param OSVersion = '2022-datacenter-azure-edition'
param securityType = 'standard'
param subnetprefix = [
  '10.0.0.0/18'
  '10.1.0.0/18'
]
param vmcount = 4
param vmSize = 'Standard_B1s'
