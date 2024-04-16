@description('Tags for the resoruces')
param resourceTags object
@description('Resource Location')
param location string
@description('Network Security Group Name')
param name array

// creation of network securuty group
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-05-01' = [for i in range(0, length(name)): {
  name: name[i]
  location: location
  tags: resourceTags
  properties: {
    securityRules: []
  }
}]
