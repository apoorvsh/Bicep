param databricksname string
param networkaccess string
param nsgrules string
param managedrgname string
param subnetname array
param subnetprefix array
param vnetname string 
param location string 
param addressprefix string 
param count int
param nsgName string
param nsgLocation string
param delegationname array
param privateEndpointName string 
param privateDNSZoneName string 
param groupID string
param tier string
param publicIP bool


var mrg = '${subscription().id}/resourceGroups/${managedrgname}'



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


@batchSize(1)
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [ for i in range(0,count): {
  name: subnetname[i]
  parent: vnet
  properties: {
     addressPrefix: subnetprefix[i]
     networkSecurityGroup: i>0 ?  {
       id: nsg.id
     } : null

      delegations:  i>0 ?  [
         {
          name : delegationname[i-1]
          properties: {
            servicename : 'Microsoft.Databricks/workspaces'
          }
         }
      ] : null       
  }
}]



resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: nsgLocation
  properties: {
    securityRules: [
      
    ]
  }
}


resource databricks 'Microsoft.Databricks/workspaces@2023-02-01' = {
  name: databricksname
  location: location
    
  sku: {
    name: tier
  }    
  properties: { 
    publicNetworkAccess: networkaccess
    requiredNsgRules:  nsgrules
    managedResourceGroupId: mrg  
    parameters: {
       enableNoPublicIp: {
        value: publicIP
       }
       customVirtualNetworkId: {
        value: vnet.id
       }
       customPrivateSubnetName: {
        value: subnetname[2]
       } 
       customPublicSubnetName: {
        value: subnetname[1]
       } 
    }
   
    
  }
  dependsOn: [
    subnet
  ]
}


 resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet[0].id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: databricks.id
          groupIds: [
            groupID
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







