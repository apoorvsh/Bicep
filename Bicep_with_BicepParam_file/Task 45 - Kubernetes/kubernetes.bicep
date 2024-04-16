param clusterName string
param location string
param dnsPrefix string
param osDiskSizeGB int
param agentCount int
param agentVMSize string
param vnetname string
param addressprefix string
param subnetname string
param subnetprefix string


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



resource aks 'Microsoft.ContainerService/managedClusters@2022-05-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.26.6' 
    dnsPrefix: dnsPrefix
    nodeResourceGroup: '' 
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
          
        vmSize: agentVMSize
        vnetSubnetID: subnet.id
        osType: 'Linux'
        mode: 'System'
      }
    ]
     networkProfile: {
       loadBalancerSku: 'standard'
       networkPlugin: 'azure'   
     }
     autoUpgradeProfile: {
       upgradeChannel: 'patch'
     } 
     disableLocalAccounts: false 
     apiServerAccessProfile: {
       enablePrivateCluster: false 
     }
     addonProfiles: {
      azurepolicy: {
        enabled: false 
      }
     }    
      
  }
}
