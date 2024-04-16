targetScope = 'tenant'

param mgName array

resource mg 'Microsoft.Management/managementGroups@2020-05-01' =  [for mgConfig in mgName: {
  name: mgConfig.name
  properties: {
    displayName: mgConfig.displayName
  }
}]

resource sub1 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' =[for mgConfig in mgName: {
  name: '${mgConfig.name}/${mgConfig.subscriptionId}'
}]

