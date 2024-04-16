param databricksname string
param networkaccess string
param nsgrules string
param managedrgname string


var mrg = '${subscription().id}/resourceGroups/${managedrgname}'



resource databricks 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: databricksname
  location: resourceGroup().location
  properties: {
 
    publicNetworkAccess: networkaccess
    requiredNsgRules:  nsgrules
    managedResourceGroupId: mrg
  }
}

