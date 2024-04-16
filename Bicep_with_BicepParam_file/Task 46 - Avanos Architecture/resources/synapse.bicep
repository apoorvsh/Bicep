param values object 








resource synapseWorkspace 'Microsoft.Synapse/workspaces@2019-06-01-preview' = {
  name: values.workSpaceName
  location: values.location
   identity: {
     type: 'SystemAssigned'
   }
  properties: {
    defaultDataLakeStorage: {
        accountUrl: format('https://{0}.dfs.core.windows.net', values.saName)
         filesystem: 'hemanglakefile'
    }
    sqlAdministratorLogin: values.sqlAdministratorLogin
    sqlAdministratorLoginPassword: values.sqlAdministratorLoginPassword
    
    
  }
 
}

output synapseId string = synapseWorkspace.id
