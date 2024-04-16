param cognitivename string
param location string
param kind string
param skuname string
param fromRecognizerName string
param vnetname string
param addressprefix string
param subnetname string
param subnetprefix string
param privateEndpointName string
param dnszonename string

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


resource cognitive 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitivename
  location: location
  kind: kind 
  sku: {
    name: skuname
  }   
  identity: {
     type: 'SystemAssigned' 
  } 
  properties: {
     customSubDomainName: fromRecognizerName
     publicNetworkAccess: 'Disabled'
     networkAcls: {
       defaultAction: 'Allow'
       ipRules: [
        
       ]
       virtualNetworkRules: [
        
       ]  
     }    
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
          privateLinkServiceId: cognitive.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
    customNetworkInterfaceName: 'HemangNic'
  }
 
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01'  existing = {
  name: dnszonename
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
