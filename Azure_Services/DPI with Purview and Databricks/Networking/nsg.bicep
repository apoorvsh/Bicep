// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string

var nsgName = [
  toLower('nsg-${projectCode}-${environment}-db01')
]

// creation of network securuty group
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = [for name in nsgName: {
  name: name
  location: location
  tags: union({
      Name: name
    }, combineResourceTags)
  properties: {
    securityRules: []
  }
}]

// output of network security groups used in subnet.bicep
output databricksNsgId string = networkSecurityGroup[0].id
