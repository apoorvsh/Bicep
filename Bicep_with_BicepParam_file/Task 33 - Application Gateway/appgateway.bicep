param vnetname string
param location string
param addressprefix string
param subnetname string
param subnetprefix string
param publicIpName string
param publicIpSku string
param publicIPAllocationMethod string
param appgatewayname string
param skuname string
param tier string
param count int
param frontendportsname array
param backendpools array
param httpsettings array
param listeners array
param routingrules array
param portnumber array
param priorities array


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

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    
  }
}


resource appgateway 'Microsoft.Network/applicationGateways@2023-04-01' = {
  name: appgatewayname
  location: location
 /* identity: {
     type:  'SystemAssigned, UserAssigned'
  } */  
  properties: {
    sku: {
       name: skuname
       tier: tier
    } 
    gatewayIPConfigurations: [
      {
        name: 'gatewayconfig'
        properties: {
           subnet: {
             id: subnet.id
           }
        }   
      } 
    ] 
    frontendIPConfigurations: [
       {
         name: 'fipgateway'
         properties: {
           publicIPAddress: {
             id: publicIp.id
           }
         }  
       }
    ]
    frontendPorts: [for i in range(0,count): {
      name: frontendportsname[i]
      properties: {
         port: portnumber[i]
      }  
      
    }] 
    
    backendAddressPools: [for i in range(0, count): {
      name: backendpools[i]
      properties: {
         backendAddresses: [
          
         ]
      }  
      
    }]
    
    httpListeners: [for i in range(0,count): {
      name: listeners[i]
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appgatewayname, 'fipgateway')
        } 
        frontendPort: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgatewayname, frontendportsname[i])
        }
      }  
      
    }] 
   
    backendHttpSettingsCollection: [for i in range(0,count): {
      name: httpsettings[i]
      properties: {
         port: 80
         protocol: 'Http'
         cookieBasedAffinity: 'Disabled'
         pickHostNameFromBackendAddress: false
         requestTimeout: 20 
      }  
      
    }]
    
     requestRoutingRules: [for i in range(0,count): {
       name: routingrules[i] 
       properties: {
        ruleType: 'Basic'
        httpListener: {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgatewayname, listeners[i])
        } 
        priority: priorities[i] 
        backendAddressPool: {
           id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appgatewayname, backendpools[i])
        }
        backendHttpSettings: {
           id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appgatewayname, httpsettings[i])
        }  
       }  
      
     }]
    
    enableHttp2: false 
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 10 
    } 
  } 
}

