param keyVaultName string 
param location string 
param objectID string 
param secrets array 
param enabledForDeployment bool 
param enabledForTemplateDeployment bool 
param enabledForDiskEncryption bool 
param enableRbacAuthorization bool 
param enableSoftDelete bool 
param softDeleteRetentionInDays int 
param publicNetworkAccess string 
param secretName string 
@secure()
param secretValue string 
param privateEndpointName string 
param vnetName string 
param vnetAddressPrefix string 
param subnetName string 
param subnetAddressPrefix string  
param privateDNSZoneName string 





resource vnet 'Microsoft.Network/virtualnetworks@2022-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:  [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualnetworks/subnets@2022-09-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetAddressPrefix
  }
  
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enableRbacAuthorization: enableRbacAuthorization
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    publicNetworkAccess: publicNetworkAccess
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
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
        objectId: objectID
        permissions: {
          secrets: secrets
        }
      }
    ]
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: secretName
  parent: keyVault
  
  properties: {
    value: secretValue
  }
 
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'HemangNic'
  }
 
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDNSZoneName
  location: 'global'
  
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: 'link'
  parent: privateDnsZone
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id 
    }
  }
 
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = {
  name: 'mydnsgroupname'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  
}
