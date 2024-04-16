param lbName string
param location string
param lbSkuName string
param lbFrontEndName string
param lbBackendPoolName string
param lbProbeName string
param lbPublicIpAddressName string
param vnetname string
param vnetaddress string
param subnetname string
param subnetprefix string
param publicipname string
param nsgName string
param scalesetname string
param instancenum int
param singlePlacementGroup bool
param VmScaleSetName string
param adminUsername string
@secure()
param adminPassword string





resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetname
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
         vnetaddress
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

resource publicip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: publicipname
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


resource lb 'Microsoft.Network/loadBalancers@2021-08-01' = {
  name: lbName
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: lbFrontEndName
        properties: {
          publicIPAddress: {
            id: lbPublicIPAddress.id
          }
        }
      }
      
    ]
    backendAddressPools: [
      {
        name: lbBackendPoolName
      }
      
    ]
    loadBalancingRules: [
      {
        name: 'myHTTPRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, lbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbBackendPoolName)
          }
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          protocol: 'Tcp'
          enableTcpReset: true
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, lbProbeName)
          }
        }
      }
    ]
    probes: [
      {
        name: lbProbeName
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    
  }
}


resource lbPublicIPAddress 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: lbPublicIpAddressName
  location: location
  sku: {
    name: lbSkuName
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}



resource symbolicname 'Microsoft.Compute/virtualMachineScaleSets@2023-07-01' = {
  name: scalesetname
  location: location
  sku: {
     capacity: instancenum
     name: 'Standard_D2s_v3'
     tier: 'Standard'  
  } 
  properties: {
    overprovision: true
    upgradePolicy: {
      mode: 'Automatic'
    }
    singlePlacementGroup: singlePlacementGroup
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          caching: 'ReadWrite'
          createOption: 'FromImage'
        }
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2022-datacenter-azure-edition'
          version: 'latest'
        }
        
      }
       osProfile: {
        computerNamePrefix: VmScaleSetName
          adminUsername: adminUsername
          adminPassword: adminPassword
       }
      networkProfile: {
          
          networkInterfaceConfigurations: [
             {
              name: 'scalenic'
              properties: {
                primary: true 
                ipConfigurations:  [
                   {
                    name: 'ipconfig'
                    properties: {
                       subnet: {
                         id: subnet.id
                       }
                       loadBalancerBackendAddressPools: [
                         {
                           id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbBackendPoolName)
                         } 
                       ]   
                    } 
                   }
                ]
                networkSecurityGroup: {
                   id: nsg.id
                } 
              } 
             }
          ]    
      }  
    } 
  }  
}


