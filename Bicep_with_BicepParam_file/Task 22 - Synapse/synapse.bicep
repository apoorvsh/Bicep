param workspaceName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param location string
param saName string




resource synapseWorkspace 'Microsoft.Synapse/workspaces@2019-06-01-preview' = {
  name: workspaceName
  location: location
   identity: {
     type: 'SystemAssigned'
   }
  properties: {
    defaultDataLakeStorage: {
        accountUrl: format('https://{0}.dfs.core.windows.net', saName)
         filesystem: 'hemanglakefile'
    }
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    
    
  }
 
}
