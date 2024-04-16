
param location string
param containername string
param applicationinsightsname string


param vnetname string
param addressprefix string
param subnetname string
param subnetprefix string
param dnszonename string
param endpointname string

var workspacename = 'hemangwork${uniqueString(resourceGroup().id)}'
var keyvaultname = 'hemangvault${uniqueString(resourceGroup().id)}'
var storageaccountname = 'hemangst${uniqueString(resourceGroup().id)}'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetname
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
         addressprefix
       ]
     }
  }  
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetname
  parent: vnet
  properties: {
    addressPrefix: subnetprefix
  }  
}




resource storageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageaccountname
  location: location
  sku: {
    name: 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyvaultname
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    enableSoftDelete: true
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationinsightsname
  location: location// (((location == 'eastus2') || (location == 'westcentralus')) ? 'southcentralus' : location)
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  sku: {
    name: 'Premium'
  }
  name: containername
  location: location
  properties: {
    adminUserEnabled: true
  }
}



resource mlworkspace 'Microsoft.MachineLearningServices/workspaces@2021-07-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  name: workspacename
  location: location
  properties: {
    friendlyName: workspacename
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
    containerRegistry: containerRegistry.id
    hbiWorkspace: true
    publicNetworkAccess: 'Disabled' 
  }
  
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: endpointname
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: endpointname
        properties: {
          privateLinkServiceId: mlworkspace.id
          groupIds: [
            'amlworkspace'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'HemangNic'
  }
 
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnszonename
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

