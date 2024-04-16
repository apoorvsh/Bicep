using './privateload.bicep'

param vnetname = 'VNET'
param location = 'Central India'
param addressprefix = '10.0.0.0/16'
param subnetname = 'subnet'
param subnetaddressprefix = '10.0.0.0/18'
param loadbalancername = 'hemangload'
param frontendipname = 'hemangfip'
param backendpoolname = 'backendpool'
param healthprobename = 'myhp'

