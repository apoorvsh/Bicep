using 'vmconfig.bicep'



param securePassword =  getSecret('e998d3e7-b93b-4cf2-8087-c1fbe787c337','Hemang_RG', 'givesomerandomnameauto','key')
param adminUsername = 'bicepvm'
param location = 'Central India'
param OSVersion = '2022-datacenter-azure-edition'
param publicIPAllocationMethod = 'Dynamic'
param publicIpName = 'myPublicIP'
param publicIpSku = 'Basic'
param securityType = 'Standard'
param vmName = 'bicepvm'
param vmSize = 'Standard_D2s_v5'
