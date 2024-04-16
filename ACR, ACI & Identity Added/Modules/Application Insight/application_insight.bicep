@description('AppLication Insight Name Name')
param name string
@description('Resource Tags')
param resourceTags object
@description('Resource Location')
param location string
param workspaceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: resourceTags
  kind: 'web'
  properties: {
    WorkspaceResourceId: workspaceId
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output instrumentKey string = applicationInsights.properties.InstrumentationKey
output applicationInsightId string = applicationInsights.id
output applicationInsightName string = applicationInsights.name
