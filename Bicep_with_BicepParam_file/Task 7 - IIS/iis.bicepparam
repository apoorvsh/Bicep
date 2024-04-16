using 'iis.bicep'

param adminPassword = 'Hemang@12345'
param adminUsername = 'bicepvm'
param location = 'Central India '
param OSVersion = '2022-datacenter-azure-edition'
param publicIPAllocationMethod = 'Dynamic'
//param publicIpName = 'myPublicIP'
param publicIpSku = 'Basic'
param securityType = 'Standard'
//param vmName = 'bicepvm'
param vmSize = 'Standard_D2s_v5'
param count = 2
//param publicIpName2 = 'pip2'
