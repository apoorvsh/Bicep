param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param keyVaultName string
param keyVaultTagName object
param keyVaultSku string
param keyVaultFamily string
@secure()
param secretsName string
@secure()
param secretsValues string
param keyVaultPrivateName string
param privateEndpointTagName object
param privateLinkServiceConnectionsName string
param dnslocation string
param dnsZoneName string
param dnsZoneTagName object
param registrationEnabled bool
param privateDnsZoneConfigsName string

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

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: subnetName
  parent: virtualNetwork
  properties: {
    addressPrefix: subnetAddress
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: resourceGroup().location
  tags: keyVaultTagName.tagA
  properties: {
    sku: {
      family:keyVaultFamily
      name: keyVaultSku
    }
    tenantId: subscription().tenantId
    accessPolicies:[ ]
  }
}

resource secrets 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secretsName
  parent: keyvault
  properties:{
    value: secretsValues
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: keyVaultPrivateName
  location: resourceGroup().location
  tags: privateEndpointTagName.tagA
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceConnectionsName
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: subnet.id
    }
  }
}

resource dnszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: dnslocation
  tags: dnsZoneTagName.tagA
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnszone.name}/${dnszone.name}-link'
  location: dnslocation
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  name: '${privateEndpoint.name}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneConfigsName
        properties: {
          privateDnsZoneId: dnszone.id
        }
      }
    ]
  }
}
