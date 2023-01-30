param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param inernalLoadBalancerName string
param internalLoadBalancerTagName object
param frontendIpConfigurationsName string
var privateIp = '10.4.1.4'
param privateIpAllocationMethod string
param loadBalancingRulesName string
param loadBalancingRulesProtocol string
param loadBalancingRulesFrontendPort int
param loadBalancingRulesBackendPort int
param enableFloatingIp bool
param idleTimeoutInMinutes int
param probeName string
param probeProtocol string
param probePort int
param intervalInSeconds int 
param numberOfProbes int 
@allowed([
  'Basic'
  'Standard'
])
param lbSku string 
var resourceID = resourceId('Microsoft.Network/loadBalancers' ,inernalLoadBalancerName)
var resourceIDB = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', inernalLoadBalancerName, '${inernalLoadBalancerName}-pool')

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: vnetTagName.tagA
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: subnetName
  parent: virtualNetwork
  properties:{ 
    addressPrefix: subnetAddress
  }
}

resource loadBalancerInternal 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: inernalLoadBalancerName
  location: resourceGroup().location
  tags: internalLoadBalancerTagName.tagA 
  sku: {
    name: lbSku
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendIpConfigurationsName
        properties: {
          privateIPAddress: privateIp
          privateIPAllocationMethod: privateIpAllocationMethod
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name:'${inernalLoadBalancerName}-pool'
      }
    ]
    loadBalancingRules: [
      {
        name: loadBalancingRulesName
        properties: {
          frontendIPConfiguration: {
            id: '${resourceID}/frontendIPConfigurations/${frontendIpConfigurationsName}'
          }
          backendAddressPool: {
            id: resourceIDB
          }
          protocol: loadBalancingRulesProtocol
          frontendPort: loadBalancingRulesFrontendPort
          backendPort: loadBalancingRulesBackendPort
          enableFloatingIP: enableFloatingIp
          idleTimeoutInMinutes: idleTimeoutInMinutes
          probe: {
            id: '${resourceID}/probes/${probeName}'
          }
        }
      }
    ]
    probes: [
      {
        name: probeName
        properties: {
          protocol: probeProtocol
          port: probePort
          intervalInSeconds: intervalInSeconds
          numberOfProbes: numberOfProbes
        }
      }
    ]
  }
}

