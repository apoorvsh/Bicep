targetScope = 'subscription'





@description('Vnet/Subnet Parameters')
param values object











resource devRG 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: values.rgNames[0]
  location: values.location
}

resource hubRG 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: values.rgNames[1]
  location: values.hublocation
  dependsOn: [
    devRG
  ]  
}

module vnetsubnet 'networking/vnetsubnet.bicep' = {
  name: values.vnetSubModuleName
  scope: devRG
  dependsOn: [
    
  ]  
  params: {
     vnetvalues: values
     nsgid: nsg.outputs.devnsgid 
     
  }
}

module hubVnetSubnet 'Hub Resources/hubVnetSubnet.bicep' = {
  scope: hubRG
  name: values.hubModuleName
  dependsOn: [
    vnetsubnet
    devRG
  ] 
  params: {
      values: values
      
     
  }
}




module nsg 'networking/nsg.bicep' =  {
  name: values.nsgModule
  scope: devRG
  params: {
    value: values
 
  
  }
}

module publicip 'networking/publicip.bicep' = {
  name: values.publicModuleName
  scope: devRG
  params: {
    value: values
    
  }
}

module hubPublicIP 'Hub Resources/publicIP.bicep' = {
  scope: hubRG
  name: values.hubpublicIpModuleName
  params: {
     value: values
  }
}

module hubToDev 'Peerings/hubToDev.bicep' = {
  scope: hubRG
  name: values.hubToDevModule
  dependsOn: [
    hubVnetSubnet
    vnetsubnet
  ]
  params: {
    devVnetID: vnetsubnet.outputs.devvnet
    values: values
  }
}

module devToHub 'Peerings/devToHub.bicep' = {
  scope: devRG
  name: values.devToHubModule
  dependsOn: [
    hubVnetSubnet
    vnetsubnet
  ]
  params: {
    hubVnetID: hubVnetSubnet.outputs.hubVnetId
    values: values
  }
}

module nic 'networking/nic.bicep' = {
  name: values.nicModule
  scope: devRG
  params: {
    values: values
    publicid: publicip.outputs.publicipid
    subnetid:vnetsubnet.outputs.vmSubnet 
  }
}

module vm 'compute/vm.bicep' = {
  name: values.vmModule
  scope: devRG
  params: {
      values: values
      nicid: nic.outputs.nicid 
  }
}


module adf 'resources/adf.bicep' = {
  name: values.adfModulename
  scope: devRG
  params: {
       values: values
    
  }
}

module keyVault 'resources/vault.bicep' = {
  name: values.vaultModuleName
  scope: devRG
  params: {
     values:values
  }
}

module adls 'resources/adls.bicep' = {
  name: values.adlsModuleName
  scope: devRG
  params: {
      values: values
  }
}



module synapseWorspace 'resources/synapse.bicep' = {
  name: values.synapseModuleName
  scope: devRG
  params: {
    values: values
  }
}

module endpoints 'Endpoints/endpoint.bicep' = {
  name: values.endpointModuleName
  scope: devRG
  params: {
     values: values
      dnsId: [ 
        dnsZones.outputs.adfDns
        dnsZones.outputs.vaultDns
        dnsZones.outputs.blobDns
        dnsZones.outputs.adlsDns
        dnsZones.outputs.synapseDns
        dnsZones.outputs.synapseDevDns
      ]
      linkServiceIds: [
        adf.outputs.adfId
        keyVault.outputs.vaultId
        adls.outputs.adlsId
        adls.outputs.adlsId
        synapseWorspace.outputs.synapseId
        synapseWorspace.outputs.synapseId
      ] 
      subnetId: vnetsubnet.outputs.devsubnet 
  }
}


module dnsZones 'Hub Resources/hubDNSZone.bicep' = {
  scope: hubRG
  name: values.hubDNSZoneModuleName
  params: {
      values: values
      vnetId: hubVnetSubnet.outputs.hubVnetId 
  }
}



module vng 'resources/vng.bicep' = {
  name:values.vngmodulename
  scope: hubRG
  dependsOn: [
    hubVnetSubnet
    hubPublicIP
    devRG 
  ]
  params: {
     values: values
     publicId:hubPublicIP.outputs.hubPublicIp
     subnetId: hubVnetSubnet.outputs.hubSubnetId
  }
}
