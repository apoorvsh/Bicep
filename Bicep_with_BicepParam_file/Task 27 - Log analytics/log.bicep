param loganalyticsworkspaceName string
param location string
param retentiondays int
param skuname string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' ={
  name: loganalyticsworkspaceName
  location: location
  properties:{
    retentionInDays: retentiondays
    sku: {
      name: skuname
    }
  }
}
