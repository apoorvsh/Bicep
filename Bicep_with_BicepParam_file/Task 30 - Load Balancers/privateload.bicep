param vnetname string
param location string
param addressprefix string
param subnetname string
param subnetaddressprefix string
param loadbalancername string
param frontendipname string
param backendpoolname string
param healthprobename string




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
     addressPrefix: subnetaddressprefix
  }  
}

resource loadbalancer 'Microsoft.Network/loadBalancers@2023-05-01' = {
  name: loadbalancername
  location: location
  sku:  {
     name: 'Standard'
     tier: 'Regional' 
  }    
  properties: {  
    frontendIPConfigurations: [ 
      {
        properties: {
           subnet: {
             id: subnet.id
           }
           privateIPAddressVersion: 'IPv4'
           privateIPAllocationMethod: 'Dynamic' 
        } 
        name: frontendipname 
      }   
    ] 
    loadBalancingRules: [
       {
        name: 'myrules' 
        properties: {
          frontendPort: 80
          protocol: 'Tcp'
          backendPort: 80
          idleTimeoutInMinutes: 15  
          frontendIPConfiguration: {
             id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', loadbalancername, frontendipname)
          } 
        } 
       }
    ] 
    probes: [
       {
         name: healthprobename
         properties: {
          port: 80
          protocol: 'Tcp'
          intervalInSeconds: 5
          numberOfProbes: 1   
         }
       }
    ]  
  }    
}

resource backendpool 'Microsoft.Network/loadBalancers/backendAddressPools@2023-05-01' = {
  name: backendpoolname
  parent: loadbalancer 
}

