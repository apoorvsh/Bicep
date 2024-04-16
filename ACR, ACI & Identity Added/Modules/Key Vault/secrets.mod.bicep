@description('Key Vault Name')
param keyVaultName string
@description('Key Vault Secrets Creation')
@secure()
param secrets_cfg object

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// creating Secrets inside Azure Key Vault
resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = [for (config, i) in secrets_cfg.secret: {
  name: config.name
  parent: keyVault
  properties: {
    value: config.value
  }
}]
