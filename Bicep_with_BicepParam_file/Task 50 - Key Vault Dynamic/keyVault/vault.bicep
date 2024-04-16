param values object 
param enableDiagnostic string
param publicAccess string

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: values.keyVaultName
  location: values.location
  properties: {
    enabledForDeployment: values.enabledForDeployment
    enabledForTemplateDeployment: values.enabledForTemplateDeployment
    enabledForDiskEncryption: values.enabledForDiskEncryption
    enableRbacAuthorization: values.enableRbacAuthorization
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    publicNetworkAccess: publicAccess=='YES' ? values.disablePublicAccess : values.enablePublicAccess
    enableSoftDelete: values.enableSoftDelete
    softDeleteRetentionInDays: values.softDeleteRetentionInDays
    networkAcls:  publicAccess=='YES' ?  {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      
    } : null /* {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: firewallIP
          
        }
      ]
    }*/
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: values.objectID
        permissions: {
          secrets: values.secrets
        }
      }
    ]
  }
}



resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: values.workSpaceName 
  scope: resourceGroup('HemangRG') 
}

resource diagno 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(enableDiagnostic=='YES') {
  name: values.diagnoName
  scope: keyVault
 properties: {
   workspaceId: logAnalytics.id //'/subscriptions/e998d3e7-b93b-4cf2-8087-c1fbe787c337/resourceGroups/Hemang_RG/providers/Microsoft.OperationalInsights/workspaces/hemangworklogs'	
   logs: [
     {
      enabled: true
      categoryGroup: 'audit'  
      
     }
   ]
 }
}


output vaultId string = keyVault.id
