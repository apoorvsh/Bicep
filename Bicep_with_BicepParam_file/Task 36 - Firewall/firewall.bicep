param vnetname string
param location string
param addressprefix string
param subnetname string
param subnetprefix string
param azurepublicIpname string
param firewallPolicyName string
param firewallname string
param publicIPname string
param tier string



resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetname
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
         addressprefix
       ]
     }
  }  
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetname
  parent: vnet
  properties: {
     addressPrefix: subnetprefix
  }  
}



resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: azurepublicIpname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2022-01-01'= {
  name: firewallPolicyName
  location: location 
  properties: {
    threatIntelMode: 'Alert'
    sku: {
       tier: tier
    } 
    intrusionDetection: {
       mode: 'Off'
    } 
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-04-01' = {
  name: firewallname
  location: location 
  properties: {
     ipConfigurations: [
       {
         name: publicIPname
         properties: {
           publicIPAddress: {
             id: publicIpAddress.id
           }
           subnet: {
             id: subnet.id
           } 
         } 
       }
     ] 
     sku: {
        tier: tier
     } 
     firewallPolicy: {
       id: firewallPolicy.id
     } 
  }  
}
