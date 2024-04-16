param nsgName string
param nsgLocation string

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: nsgLocation
  properties: {
    securityRules: [
      
    ]
  }
}
