param vnetName string
param vnetTagName object
param vnetAddress string
param subnetName string
param subnetAddress string
param applicationGatewayName string
param applicationGatewayTagName object
param applicationGatewaySkuName string
param applicationGatewaySkuTier string
param applicationGatewaySkuCapacity int
param gatewayIpConfigurationsName string
param frontendIpConfigurationsName string
param publicIpName string
param pulicIpTagName object
param publicIpSkuName string
param publicIpSkuTier string
param publicIpAllocationMethod string
param frontendPortName string
param frontendPortPort int
param backendHttpSettingsCollectionName string
param backendHttpSettingsCollectionPort int
param backendHttpSettingsCollectionProtocol string
param cookieBasedAffinity string
param httpListenersName string
var resourceIDA = resourceId('Microsoft.Network/applicationGateways', applicationGatewayName)
param httpListenersProtocol string
param requestRoutingRulesName string
param requestRoutingRulesRuleType string
var resouceIDB = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, '${applicationGatewayName}-pool')

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
  properties: {
    addressPrefix: subnetAddress
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: applicationGatewayName
  location: resourceGroup().location
  tags: applicationGatewayTagName.tagA
  properties: {
    sku: {
      name: applicationGatewaySkuName 
      tier: applicationGatewaySkuTier
      capacity: applicationGatewaySkuCapacity
    }
    gatewayIPConfigurations: [
      {
        name: gatewayIpConfigurationsName
        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
         name: frontendIpConfigurationsName
         properties: {
          publicIPAddress: {
            id: publicip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendPortName
        properties: {
          port: frontendPortPort
        }
      }
    ]
    backendAddressPools: [
      {
        name: '${applicationGatewayName}-pool'
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: backendHttpSettingsCollectionName
        properties: {
          port: backendHttpSettingsCollectionPort
          protocol: backendHttpSettingsCollectionProtocol
          cookieBasedAffinity: cookieBasedAffinity
        }
      }
    ]
    httpListeners: [
      {
        name: httpListenersName
        properties: {
          frontendIPConfiguration: {
            id: '${resourceIDA}/frontendIPConfigurations/${frontendIpConfigurationsName}'
          }
          frontendPort: {
            id: '${resourceIDA}/frontendPorts/${frontendPortName}'
          }
          protocol: httpListenersProtocol
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: requestRoutingRulesName
        properties: {
          ruleType: requestRoutingRulesRuleType
          httpListener: {
            id: '${resourceIDA}/httpListeners/${httpListenersName}'
          }
          backendAddressPool: {
            id: resouceIDB
          }
          backendHttpSettings: {
            id: '${resourceIDA}/backendHttpSettingsCollection/${backendHttpSettingsCollectionName}'
          }
        }
      }
    ]
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name:  publicIpName
  location: resourceGroup().location
  tags: pulicIpTagName.tagA
  sku: {
     name: publicIpSkuName
     tier: publicIpSkuTier
    }
  properties: {
    publicIPAllocationMethod: publicIpAllocationMethod
  }
} 
