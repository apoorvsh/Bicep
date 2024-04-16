using './publicload.bicep'

param lbName = 'hemangload'
param location = 'East US'
param lbSkuName = 'Standard'
param lbFrontEndName = 'fip'
param lbBackendPoolName = 'backend'
param lbProbeName = 'myhp'
param lbPublicIpAddressName = 'lbip'

