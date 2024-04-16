using 'loopvnet.bicep'

param vnetAddressPrefix = '10.1.0.0/16'
param vnetLocation = 'East US'
param vnetName = 'myloopVnet'
param subnetNames = [
  'subnet1'
  'subnet2'
]
param subnetPrefixes = [
  '10.1.64.0/18'
  '10.1.128.0/18'
]
