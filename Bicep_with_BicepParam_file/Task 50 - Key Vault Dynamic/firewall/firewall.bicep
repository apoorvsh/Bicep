param values object
param firewallIPID string
param subnetID string

resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' = {
  name: values.firewallName
  location: values.location
  ///zones: ((length(availabilityZones) == 0) ? null : availabilityZones)
  
  properties: {
    ipConfigurations:  [
       {
         name:values.firwallIPConfig
         properties: {
           publicIPAddress:  {
             id: firewallIPID
           }
           subnet: {
             id: subnetID
           } 
         } 
       }
    ]
    
  }
}
