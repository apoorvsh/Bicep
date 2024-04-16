param SqlServerName string
param SqlDatabase string 
param adminLogin string
@secure()
param adminPassword string
param location string

resource sqlServer 'Microsoft.Sql/servers@2023-02-01-preview' = {
  name: SqlServerName
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-02-01-preview' = {
  name: SqlDatabase
  parent: sqlServer
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    
  }
}


