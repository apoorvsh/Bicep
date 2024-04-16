using './ml.bicep'


param location = 'centralindia'
param containername = 'hemangcontainer'
param applicationinsightsname = 'hemanginsights'


param vnetname = 'vnet'
param addressprefix = '10.0.0.0/16'
param subnetname = 'subnet'
param subnetprefix = '10.0.0.0/18'
param dnszonename = 'privatelink.api.azureml.ms'
param endpointname = 'hemangendpoint'

