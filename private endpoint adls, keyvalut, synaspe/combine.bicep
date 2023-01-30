param vnetName string
param vnetAddress string
param vnetTagName object
param subnetName string
param subnetAddress string
param keyVaultName string
param keyVaultTagName object
param enabledForDeployment bool
param enabledForTemplateDeployment bool
param enabledForDiskEncryption bool
param tenantID string = subscription().tenantId
param objectId string
param keysPermission string
param secretsPermission string
param keyVaultSkuName string
param keyVaultSkuFamily string
param keyVaultNameA string
@secure()
param sqlAdminUserName string
param keyVaultNameB string
@secure()
param sqlPassword string
param keyVaultPrivateEndpointName string
param keyVaultPrivateEndpointTagName object
param keyVaultPrivateLinkServiceConnectionsName string
param keyVaultGroupId string
param keyVaultDnsZoneName string
param keyVaultDnsZoneLocation string
param keyVaultDnsZoneTagName object
param keyVaultVnetLinkLocation string
param keyVaultRegistrationEnabled bool
param keyVaultPrivateDnsZoneConfigs string
param storageName string
param storageAccountTagName object
param storageKind string
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param storageSku string
param storageAccessTier string
param allowBlobPublicAccess bool
param allowSharedKeyAccess bool
param ishnsEnabled  bool
param blobEnabled bool
param fileEnabled bool
param queueEnabled bool
param tableEnabled bool
param storageAccountPrivateEndpointName string
param storageAccountPrivateEndpointTagName object
param storageAccountPrivateLinkServiceConnectionsName string
param storageAccountGroupId string
param storageAccountDnsZoneName string
param storageAccountDnsZoneTagName object
param storageAccountDnsZoneLocation string
param storageAccountVnetLinkLocation string
param storageAccountRegistrationEnabled bool
param storageAcccountPrivateDnsZoneConfigs string
param synapseName string
param synapseTagName object
@secure()
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param storageAccountUrl string
param fileSystemName string
param synapsePrivateEndpointName string
param synapsePrivateEndpointTagName object
param synapsePrivateLinkServiceConnectionsName string
param synapseGroupId string
param synapseDnsZoneName string
param synapseDnsZoneLocation string
param synapseDnsZoneTagName object 
param synapseVnetLinkLocation string
param synapseRegistrationEnabled bool
param synapsePrivateDnsZoneConfigs string
param synapsePrivateLinkHubName string
param synapsePrivateLinkHubTagName object
param synapsePrivateLinkHubEndpointName string
param synapsePrivateLinkHubEndpointTagName object
param synapsePrivateLinkHubGroupId string
param synapsePrivateLinkHubDnsZoneName string
param synapsePrivateLinkHubDnsZoneLocation string
param synapsePrivateLinkHubDnsZoneTagName object
param synapsePrivateLinkHubVnetLinkLocation string
param synapsePrivateLinkHubRegistrationEnabled bool
param synapsePrivateLinkHubPrivateDnsZoneConfigs string
param synapsePrivateLinkHubPrivateLinkServiceConnectionsName string
param dedicatedSqlPoolName string
param dedicatedSqlPoolTagName object
param dedicatedSqlPoolSkuCapacity int
param dedicatedSqlPoolSkuName string
param dedicatedSqlPoolSkuTier string
param dedicatedSqlPoolPrivateEndpointName string
param dedicatedSqlPoolPrivateEndpointTagName object
param dedicatedSqlPoolPrivateLinkServiceConnectionsName string
param dedicatedSqlPoolGroupId string
param dedicatedSqlPoolDnsZoneName string
param dedicatedSqlPoolDnsZoneLocation string
param dedicatedSqlPoolDnsZoneTagName object
param dedicatedSqlPoolVnetLinkLocation string
param dedicatedSqlPoolRegistrationEnabled bool
param dedicatedSqlPoolPrivateDnsZoneConfigs string
param apacheSparkPoolName string
param apacheSparkPoolTagName object
param sparkNodeSize string
param sparkPoolNodeSizeFamily string
param sparkPoolDelayInMinutes int
param sparkPoolAutoPauseEnable bool
param sparkPoolAutoScaleEnable bool
param sparkPoolMaxNodeCount int
param sparkPoolMinNodeCount int
param saprkPoolDynamicExecutorAllocation bool
param sparkVersion string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: vnetTagName.tagA
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddress
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: resourceGroup().location
  tags: keyVaultTagName.tagA
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    tenantId: tenantID
    accessPolicies: [
      {
        tenantId: tenantID
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
      name: keyVaultSkuName
      family: keyVaultSkuFamily
    }
  }
}

resource userNameKeyVault 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: keyVaultNameA
  parent: keyVault
  properties: {
    value: sqlAdminUserName
  }
}

resource passwordKeyVault 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: keyVaultNameB
  parent: keyVault
  properties: {
    value: sqlPassword
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: keyVaultPrivateEndpointName
  location: resourceGroup().location
  tags: keyVaultPrivateEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: keyVaultPrivateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            keyVaultGroupId
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource keyVaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: keyVaultDnsZoneName
  location: keyVaultDnsZoneLocation
  tags: keyVaultDnsZoneTagName.tagA  
}

resource keyVaultVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${keyVaultDnsZone.name}/${keyVaultDnsZone.name}-link'
  location: keyVaultVnetLinkLocation
  properties: {
    registrationEnabled: keyVaultRegistrationEnabled
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource keyVaultDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${keyVaultPrivateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: keyVaultPrivateDnsZoneConfigs
        properties: {
          privateDnsZoneId: keyVaultDnsZone.id
        }
      }
    ]
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageName
  location: resourceGroup().location
  tags: storageAccountTagName.tagA
  kind: storageKind
  sku: {
    name: storageSku
  }
  properties: {
    accessTier: storageAccessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    isHnsEnabled: ishnsEnabled
    services: {
        blob: {
          enabled: blobEnabled
          
        }
        file: {
          enabled: fileEnabled
         
        }
        queue: {
          enabled: queueEnabled
         
        }
        table: {
          enabled: tableEnabled
        }    
    }
  }
}

resource storageAccountPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: storageAccountPrivateEndpointName
  location: resourceGroup().location
  tags: storageAccountPrivateEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: storageAccountPrivateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            storageAccountGroupId
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource storageAccountDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: storageAccountDnsZoneName
  location: storageAccountDnsZoneLocation
  tags: storageAccountDnsZoneTagName.tagA  
}

resource storageAccountVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${storageAccountDnsZone.name}/${storageAccountDnsZone.name}-link'
  location: storageAccountVnetLinkLocation
  properties: {
    registrationEnabled: storageAccountRegistrationEnabled
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource storageAccountDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${storageAccountPrivateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: storageAcccountPrivateDnsZoneConfigs
        properties: {
          privateDnsZoneId: storageAccountDnsZone.id
        }
      }
    ]
  }
}

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: resourceGroup().location
  tags: synapseTagName.tagA
   identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    defaultDataLakeStorage: {
    accountUrl: storageAccountUrl
    filesystem: fileSystemName
    }
  }
}

resource synapsePrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: synapsePrivateEndpointName
  location: resourceGroup().location
  tags: synapsePrivateEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: synapsePrivateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            synapseGroupId
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource synapseDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: synapseDnsZoneName
  location: synapseDnsZoneLocation
  tags: synapseDnsZoneTagName.tagA  
}

resource synapseVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${synapseDnsZone.name}/${synapseDnsZone.name}-link'
  location: synapseVnetLinkLocation
  properties: {
    registrationEnabled: synapseRegistrationEnabled
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource synapseDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${synapsePrivateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: synapsePrivateDnsZoneConfigs
        properties: {
          privateDnsZoneId: synapseDnsZone.id
        }
      }
    ]
  }
}

resource synapsePrivateLinkHubs 'Microsoft.Synapse/privateLinkHubs@2021-06-01' = {
  name: synapsePrivateLinkHubName 
  location: resourceGroup().location
  tags: synapsePrivateLinkHubTagName.tagA
}

resource synapsePrivateLinkHubPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: synapsePrivateLinkHubEndpointName
  location: resourceGroup().location
  tags: synapsePrivateLinkHubEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: synapsePrivateLinkHubPrivateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: synapsePrivateLinkHubs.id
          groupIds: [
            synapsePrivateLinkHubGroupId
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource synapsePrivateLinkHubDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: synapsePrivateLinkHubDnsZoneName
  location: synapsePrivateLinkHubDnsZoneLocation
  tags: synapsePrivateLinkHubDnsZoneTagName.tagA  
}

resource synapsePrivateLinkHubVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${synapsePrivateLinkHubDnsZone.name}/${synapsePrivateLinkHubDnsZone.name}-link'
  location: synapsePrivateLinkHubVnetLinkLocation
  properties: {
    registrationEnabled: synapsePrivateLinkHubRegistrationEnabled
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource synapsePrivateLinkHubDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${synapsePrivateLinkHubPrivateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: synapsePrivateLinkHubPrivateDnsZoneConfigs
        properties: {
          privateDnsZoneId: synapsePrivateLinkHubDnsZone.id
        }
      }
    ]
  }
}

resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name : dedicatedSqlPoolName
  location: resourceGroup().location
  tags: dedicatedSqlPoolTagName.tagA
  parent: synapse
  sku: {
    capacity: dedicatedSqlPoolSkuCapacity
    name: dedicatedSqlPoolSkuName
    tier: dedicatedSqlPoolSkuTier
  }
  properties: {
  }
}

resource dedicatedSqlPoolPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: dedicatedSqlPoolPrivateEndpointName
  location: resourceGroup().location
  tags: dedicatedSqlPoolPrivateEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: dedicatedSqlPoolPrivateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            dedicatedSqlPoolGroupId
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource dedicatedSqlPoolDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dedicatedSqlPoolDnsZoneName
  location: dedicatedSqlPoolDnsZoneLocation
  tags: dedicatedSqlPoolDnsZoneTagName.tagA  
}

resource dedicatedSqlPoolVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dedicatedSqlPoolDnsZone.name}/${dedicatedSqlPoolDnsZone.name}-link'
  location: dedicatedSqlPoolVnetLinkLocation
  properties: {
    registrationEnabled: dedicatedSqlPoolRegistrationEnabled
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource dedicatedSqlPoolDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${dedicatedSqlPoolPrivateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: dedicatedSqlPoolPrivateDnsZoneConfigs
        properties: {
          privateDnsZoneId: dedicatedSqlPoolDnsZone.id
        }
      }
    ]
  }
}

resource apacheSparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01' = {
  name: apacheSparkPoolName
  location: resourceGroup().location
  tags: apacheSparkPoolTagName.tagA
  parent: synapse
  properties: {
     sparkVersion: sparkVersion
    nodeSize: sparkNodeSize
    nodeSizeFamily: sparkPoolNodeSizeFamily
    autoPause: {
      delayInMinutes: sparkPoolDelayInMinutes
      enabled: sparkPoolAutoPauseEnable
    }
    autoScale: {
      enabled: sparkPoolAutoScaleEnable
      maxNodeCount: sparkPoolMaxNodeCount
      minNodeCount: sparkPoolMinNodeCount
    }
    dynamicExecutorAllocation: {
      enabled: saprkPoolDynamicExecutorAllocation
    }
  }
}










