param workspaceName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param location string
param saName string
param sparkname string
param sqlpoolname string
param firewallRuleName array
param firewallRulesEnd array
param firewallRulesStart array

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

resource firewallRules 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = [for i in range(0,2): {
  name: firewallRuleName[i]
  parent: synapseWorkspace
  properties: {
    endIpAddress: firewallRulesEnd[i]
    startIpAddress: firewallRulesStart[i]
  }
  
}]

resource sparkpool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: sparkname
  location: location
  parent: synapseWorkspace
  properties: {
     autoPause: {
       delayInMinutes: 15
       enabled: true
     }
     nodeSize: 'Medium'
     nodeSizeFamily: 'MemoryOptimized'
     sparkVersion: '2.4'  
     autoScale: {
       enabled: true
       maxNodeCount: 10
       minNodeCount: 3  
     }  
  }
}


resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name: sqlpoolname
  location: location
  parent: synapseWorkspace
  
}
