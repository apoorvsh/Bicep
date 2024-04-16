param values object

targetScope = 'subscription'


resource resourceGroup1 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: values.rgNames
  location: values.location
}

module vnet 'vnetsubnet.bicep' = {
  scope: resourceGroup1
  name: values.vnetModuleName
  params: {
    nsgid: nsg.outputs.nsgid
    values: values
  }
}

module nsg 'nsg.bicep' = {
  scope: resourceGroup1
  name: values.nsgModuleName
  params: {
    value: values
  }
}

module adf 'adf.bicep' = {
  scope: resourceGroup1
  name: values.adfModuleName
  params: {
    values: values
  }
}

module storage 'storage.bicep' = {
  scope: resourceGroup1
  name: values.storageModuleName
  dependsOn: [
    adf
  ] 
  params: {
    values: values
  }
}

module endpoints 'endpoints.bicep' = {
  scope: resourceGroup1
  name: values.endpointsModuleName
  params: {
    dnsId:  [
      dnsZones.outputs.adfDns
      dnsZones.outputs.adlsDns
      dnsZones.outputs.blobDns
      dnsZones.outputs.fileDns
      dnsZones.outputs.queueDns
      dnsZones.outputs.tableDns
    ]
    linkServiceIds:  [
      adf.outputs.adfId
      storage.outputs.adlsId
    ]
    subnetId: [
      vnet.outputs.adfSubnet
      vnet.outputs.storageSubnet
    ]
    values: values
  }
}

module dnsZones 'dnszone.bicep' = {
  scope: resourceGroup1
  name: values.dnsModulename
  params: {
    values: values
    vnetId: vnet.outputs.vnetID
  }
}


// https://jasonmasten.com/2021/04/13/tenant-id-application-id-principal-id-and-scope-are-not-allowed-to-be-updated/
