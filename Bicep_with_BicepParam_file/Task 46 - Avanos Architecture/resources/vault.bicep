param values object 







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
    publicNetworkAccess: values.publicNetworkAccess
    enableSoftDelete: values.enableSoftDelete
    softDeleteRetentionInDays: values.softDeleteRetentionInDays
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: '192.84.190.235'
          
        }
      ]
    }
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


output vaultId string = keyVault.id
