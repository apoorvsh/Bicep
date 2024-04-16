using './scaleset.bicep'

param lbName = 'hemangload'
param location = 'East US'
param lbSkuName = 'Standard'
param lbFrontEndName = 'hemangfip'
param lbBackendPoolName = 'hemangbackend'
param lbProbeName = 'myhp'
param lbPublicIpAddressName = 'lbip'
param vnetname = 'VNET'
param vnetaddress = '10.0.0.0/16'
param subnetname = 'subnet'
param subnetprefix = '10.0.0.0/18'
param publicipname = 'publicip'
param nsgName = 'nsg'
param scalesetname = 'vmscaleset'
param instancenum = 2
param singlePlacementGroup = true
param VmScaleSetName = 'vmscale'
param adminUsername = 'adminhemang'
param adminPassword = 'Hemang@12345'

