using './cognitive.bicep'

param cognitivename = 'hemangcognitive'
param location = 'centralindia'
param kind = 'FormRecognizer'
param skuname = 'S0'
param fromRecognizerName = 'hemangform'
param vnetname = 'vnet'
param addressprefix = '10.0.0.0/16'
param subnetname = 'subnet'
param subnetprefix = '10.0.0.0/18'
param privateEndpointName = 'hemangendpoint'
param dnszonename = 'privatelink.cognitiveservices.azure.com'

