param name string
param location string

resource accessconnect 'Microsoft.Databricks/accessConnectors@2022-10-01-preview' = {
  name: name
  location: location
}
