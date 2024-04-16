using './vng.bicep'

param vnetname = 'hemangvnet'
param location = 'centralindia'
param addressprefix = '10.0.0.0/16'
param subnetname = 'GatewaySubnet'
param subnetprefix = '10.0.0.0/18'
param publicipname = 'cngpublicIP'
param vngname = 'hemangvng'
param disable = false
param gatewaytype = 'Vpn'
param tier =  'VpnGw2AZ'
param vpntype = 'RouteBased'
param generation = 'Generation2'

