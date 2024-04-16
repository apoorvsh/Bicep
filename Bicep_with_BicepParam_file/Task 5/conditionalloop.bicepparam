using 'conditionalloop.bicep'

param networkSecurityGroupName  = 'nsg01'
param location = 'East US'

param vnetAddressPrefix = [
  '10.0.0.0/16'
  '10.1.0.0/16'
]
param subnet1Name = [
  'subnet1a'
  'subnet1b'
]
param subnet2Name = [
  'subnet2a'
  'subnet2b'
]
param subnet1AddressPrefix = [
  '10.0.1.0/24'
  '10.1.1.0/24'
]
param subnet2AddressPrefix = [
  '10.0.2.0/24'
  '10.1.2.0/24'
]

param count = 2
