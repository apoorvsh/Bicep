targetScope = 'subscription'

param values object
@allowed([
  'YES'
  'NO'
])
param adminRoleCondition string
@allowed([
  'YES'
  'NO'
])
param contributorRoleCondition string
@allowed([
  'YES'
  'NO'
])
param endpointCondition string
@allowed([
  'YES'
  'NO'
])
param enableDiagnostic string



resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: values.rgNames
  location: values.location
}


module vnet  'subnetvnet/vnet.bicep' = {
  scope: resourceGroup
  name: values.vnetModuleName
  params: {
    values: values
  }
}

module keyVault 'keyVault/vault.bicep' = {
  scope: resourceGroup
  name: values.vaultModuleName
  params: {
    values: values
    enableDiagnostic: enableDiagnostic
    publicAccess: endpointCondition
  }
}



module endpoint 'endpoints/endpoints.bicep' = if (endpointCondition=='YES') {
  scope: resourceGroup
  name: values.endpointModule
  params: {
    keyVaultID: keyVault.outputs.vaultId
    privateDnsZoneID: dnsZones.outputs.dnsID
    subnetID: vnet.outputs.subnetID
    values: values
  }  
  
}


module dnsZones 'dnsZones/dns.bicep' = if (endpointCondition=='YES') {
  scope: resourceGroup
  name: values.dnsModulename
  params: {
    values: values
    vnetID: vnet.outputs.vnetId
  }  
}


module adminRole 'adminRole/adminrole.bicep' = if (adminRoleCondition=='YES') { 
  scope: resourceGroup
   name: values.adminModuleName
   dependsOn: [
    keyVault
   ]
   params: {
    values: values
   }  
}

module contributorRole 'contributorRole/contributorRole.bicep' = if (contributorRoleCondition=='YES') {
  scope: resourceGroup
  name: values.contributorModuleName 
  dependsOn: [
    keyVault
  ]
  params: {
    values: values
  }
} 

