using './nat.bicep'

param publicipname = 'natip'
param location = 'East US'
param vnetname = 'VNET'
param vnetaddress = '10.0.0.0/16'
param subnetname = 'subnet'
param subnetprefix = '10.0.0.0/18'
param natgatewayname = 'natg'

