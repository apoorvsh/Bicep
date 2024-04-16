using 'bastion.bicep'

param publicIpAddressName = 'myPublicIP'
param vnetName = 'myVNet'
param vnetIpPrefix = '10.2.0.0/16'
param bastionSubnetName = 'AzureBastionSubnet'
param bastionSubnetIpPrefix = '10.2.1.0/26'
param bastionHostName = 'bastion'
param nsgName = 'BastionNSG'
param location = 'Central India'
