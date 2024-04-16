targetScope = 'subscription'

@description('Location for the all the Azure Services')
param location string 
@description('Tags for the resoruces')
param resourceTags object
param environment string
param domainName string
@description('Resource Group Name')
param resourceGroupName string
@description('Exisiting Virtual Network Resource Group Name')
param vnetResourceGroupName string
@description('Existing Virtual Network Name')
param vnetName string
@description('Private Endpoint Subnet Name')
param pvSubnetName string
param privateZoneDnsID array
@description('Network Access Public or Private')
@allowed([
  'Public'
  'Private' ])
param networkAccessApproach string
param acrSku string
param firewallIPEnable string
param image string
param cpu int
param memory string
param osType string
param aciSku string
param ipPort int
param ipProtocol string


var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}

var resourceNames = {
  acrName: toLower('${environment}-${locationMap[location]}-${domain}-acr')
  aciName: toLower('${environment}-${locationMap[location]}-${domain}-aci')
  //aiMultiServiceaAccountName: toLower('${environment}-${locationMap[location]}-${domain}-msaccount01')
  privateEndpointName: [
    toLower('${environment}-${locationMap[location]}-${domain}-pv-registry')
   
  ]
  privateEndpointNicNames: [
    toLower('${environment}${locationMap[location]}${domain}nicregistry')
    
  ]
}
var groupIDs = [
  'registry'
]

var resourceID = [
  acr.outputs.acrID
]

module resourceGroup_Creation '../../../Modules/Resource Group/resource_group.mod.bicep' = {
  name: resourceGroupName
  params: {
    location: location
    name: resourceGroupName
    resourceTags: resourceTags
  }
}

module acr '../../../Modules/App Modenization/acr.bicep' = {
  name: 'deployAcr'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    acrName: resourceNames.acrName
    firewallIPEnable: firewallIPEnable
    location: location
    publicAccess: networkAccessApproach
    sku: acrSku
  }
}

module aci '../../../Modules/App Modenization/aci.bicep' = {
  name: 'deployAci'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    cpu: cpu
    image: image
    instanceName: resourceNames.aciName
    ipPort: ipPort
    ipProtocol: ipProtocol
    ipType: networkAccessApproach
    location: location
    memory: memory
    osType: osType
    sku: aciSku
    subnetID: pvSubnetName
  }
}

module pvtEndpoint '../../../Modules/Network/private_endpoint.mod.bicep' = {
  scope: resourceGroup(resourceGroup_Creation.name)
  name: 'deployAcrEndpoint'
  params: {
    groupIDs: groupIDs
    location: location
    privateEndpointName: resourceNames.privateEndpointName
    privateEndpointNicNames: resourceNames.privateEndpointNicNames
    pvSubnetName: pvSubnetName
    resourceID: resourceID
    resourceTags: resourceTags
    vnetName: vnetName
    vnetResourceGroupName: vnetResourceGroupName
  }
}

module pvtDNSZones '../../../Modules/Network/private_dns_zone_group.mod.bicep' = {
  scope: resourceGroup(resourceGroup_Creation.name)
  name: 'deploypvtAcrDNS'
  params: {
    privateDnsZoneID: privateZoneDnsID
    privateEndpointName: resourceNames.privateEndpointName
  }
}
