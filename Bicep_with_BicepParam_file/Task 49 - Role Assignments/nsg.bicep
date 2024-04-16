param value object


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: value.nsgName
  location: value.location
  properties: {
    securityRules: [
      
    ]
  }
}


output nsgid string = nsg.id
