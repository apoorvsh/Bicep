param keyVaultName string
param keyVaultLocation string = resourceGroup().location
param keyVaultTagName object
param enabledForDeployment bool
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool
param enableRbacAuthorization bool
param tenantId string = subscription().tenantId
param objectId string
param keysPermission string
@secure()
param secretsPermission string
param skuName string
param skuFamily string
param keyVaultNameA string
@secure()
param userName string
param keyVaultNameB string
@secure()
param password string

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: keyVaultLocation
  tags: keyVaultTagName.tagA
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
    tenantId: tenantId
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          keys: [
            keysPermission
          ]
          secrets: [
            secretsPermission
          ]
        }
      }
    ]
    sku: {
      name: skuName
      family: skuFamily
    }
  }
}

resource userNameKeyVault 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: keyVaultNameA
  parent: keyVault
  properties: {
    value: userName
  }
}

resource passwordKeyVault 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: keyVaultNameB
  parent: keyVault
  properties: {
    value: password
  }
}
