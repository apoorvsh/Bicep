using './appgateway.bicep'

param vnetname = 'vnet'
param location = 'East US'
param addressprefix = '10.0.0.0/16'
param subnetname = 'subnet'
param subnetprefix = '10.0.0.0/18'
param publicIpName = 'publicIP'
param publicIpSku = 'Standard'
param publicIPAllocationMethod = 'Static'
param appgatewayname = 'myappgateway'
param skuname = 'Standard_v2'
param tier = 'Standard_v2'
param count = 2
param frontendportsname = [
  'port_80'
  'port_8080'
]
param backendpools = [
  'bpool1'
  'bpool2'
]
param httpsettings = [
  'httpsettings1'
  'httpsettings2'
]
param listeners = [
  'mylistener1'
  'mylistener2'
]
param routingrules = [
  'routingrule1'
  'routingrule2'
]
param portnumber = [
  80
  8080
]

param priorities = [
  100
  101
]
