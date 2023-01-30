param vnetName string
param moduleNameSubnetA string
param subnetaddressPrefixA string 
param subnetNameA string
param moduleNameSubnetB string
param subnetaddressPrefixB string
param subnetNameB string

module subnetA './creationsubnetA.bicep' = {
  name: moduleNameSubnetA
  scope: resourceGroup('spokerg')
  params: { 
    subnetaddressPrefixA: subnetaddressPrefixA
    subnetNameA: subnetNameA
    vnetName: vnetName 
  }
}

module subnetB './creationsubnetB.bicep' = {
  name: moduleNameSubnetB
  scope: resourceGroup('spokerg')
  params: { 
    subnetaddressPrefixB: subnetaddressPrefixB
    subnetNameB: subnetNameB
    vnetName: vnetName
  }
}
