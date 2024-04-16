using './traffic.bicep'

param trafficname = 'hemangtraffic'
param location = 'global'
param endpointnames = [
  'endpoint1'
  'endpoint2'
]
param targetnames = [
  'www.microsoft.com'
  'www.google.com'
]
param endpointlocations = [
  'eastus'
  'centralindia'
]
param endpointstatus = 'Enabled'
param count = 2

param uniquedns = 'hemanguniquedns'
param ttl = 30
