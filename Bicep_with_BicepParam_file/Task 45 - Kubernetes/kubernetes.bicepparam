using './kubernetes.bicep'

param clusterName = 'hemangaks'
param location = 'centralindia'
param dnsPrefix = 'hemangdns'
param osDiskSizeGB = 0
param agentCount = 1
param agentVMSize = 'standard_d2s_v3'
param vnetname = 'vnet'
param addressprefix = '10.1.0.0/16'
param subnetname = 'subnet'
param subnetprefix = '10.1.0.0/18'

