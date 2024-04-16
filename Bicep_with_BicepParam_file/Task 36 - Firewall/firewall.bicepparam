using './firewall.bicep'

param vnetname = 'vnet'
param location = 'centralindia'
param addressprefix = '10.0.0.0/16'
param subnetname = 'AzureFirewallSubnet'
param subnetprefix = '10.0.0.0/18'
param azurepublicIpname = 'fpublicIP'
param firewallPolicyName = 'fpolicy'
param firewallname = 'hemangfirewall'
param publicIPname = 'publicIP'
param tier = 'Premium'

