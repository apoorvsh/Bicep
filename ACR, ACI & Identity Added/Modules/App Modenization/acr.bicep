param acrName string
param location string
param sku string
param publicAccess string
param firewallIPEnable string


resource acr 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: sku
  }
   
  properties: {
       
     adminUserEnabled: false
     publicNetworkAccess: publicAccess=='Yes' || firewallIPEnable=='Yes' ? 'Enabled' : 'Disabled' 
     networkRuleBypassOptions: publicAccess=='No' ? 'AzureServices' : 'None'
     dataEndpointEnabled:  true                 
     networkRuleSet: {
     defaultAction:  publicAccess=='Yes' && firewallIPEnable == 'No' ? 'Allow' : 'Deny'
     ipRules: firewallIPEnable=='Yes' ?  [
         {
          value: '1.2.3.4'
         }
      ] : null 
     } 
  } 
}

output acrID string = acr.id
