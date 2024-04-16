// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Existing Key Vault Private DNS Zone')
param existingDatabricksPrivateDnsZoneId string
// parameters
@description(' Web Subnet Id for Prviate Endpoint')
param subnetRef string
@description('Virtual Network Name')
param vnetName string
@description('VnetId for Prviate Endpoint')
param vnetId string
@description('DataBricks Host Subnet Name')
param databricksHostSubnetName string
@description('Databricks Container Subnet Name')
param databricksContainerSubnetName string

// variables
@description('The name of the Azure Databricks Access Connector to create.')
var dataBricksAccessConnectorName = toLower('dbwcon-${projectCode}-${environment}-databricks01')
@description('The name of the Azure Databricks workspace to create.')
var databricksWorkspaceName = toLower('dbw-${projectCode}-${environment}-databricks01')
@description('The pricing tier of workspace.')
var pricingTier = 'premium'
@description('DataBricks Priavte Endpoint Name')
var databricksPrivateEndpointName_ui_api = toLower('pep-${projectCode}-${environment}-dbwfe01')
@description('Network Interface Name for Databricks Private Endpoint')
var ui_apiCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}dbwfe01')
@description('Target Sub Resource of Azure Data Bricks')
var ui_api_groupId = 'databricks_ui_api'
@description('Azure DataBricks Private Endpoint')
var databricksPrivateEndpointName_browser_auth = toLower('pep-${projectCode}-${environment}-dbwbe01')
@description('Network Interface Name for Databricks Private Endpoint')
var browser_authCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}dbwbe01')
@description('Target Sub Resource of Azure DataBricks')
var browser_auth_groupId = 'browser_authentication'
@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
var disablePublicIp = networkAccessApproach == 'Private' ? bool(true) : bool(false)
@description('Databricks Managed Resource Group Name')
var managedResourceGroupName = 'managed-rg-${databricksWorkspaceName}'
@description('Databricks Public Network Access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
@description('Require Infrastructure Encryption')
var requireInfrastructureEncryption = true
var databricksPrivateDnsZoneName = 'privatelink.azuredatabricks.net'
var databricks_ui_api_PvtEndpointDnsGroupName = '${databricksPrivateEndpointName_ui_api}/mydnsgroupname'
var databricks_browser_auth_PvtEndpointDnsGroupName = '${databricksPrivateEndpointName_browser_auth}/mydnsgroupname'
var networkApproach = {
  Public: {
    vnetId: null
    customPublicSubnetName: null
    customPrivateSubnetName: null
    requiredNsgRules: null
    // Updating required Virtual Network from to /subscriptions/0c267d19-0a1d-449d-8f6d-88536cb2f4ca/resourceGroups/rg-ct-test-network01/providers/Microsoft.Network/virtualNetworks/vnet-ct-test-network01 is currently not allowed. Click here for details
  }
  Private: {
    vnetId: json('{"value": "${vnetId}"}')
    customPublicSubnetName: json('{"value": "${databricksHostSubnetName}"}')
    customPrivateSubnetName: json('{"value": "${databricksContainerSubnetName}"}')
    requiredNsgRules: 'NoAzureDatabricksRules'
    // Updating required Virtual Network from to /subscriptions/0c267d19-0a1d-449d-8f6d-88536cb2f4ca/resourceGroups/rg-ct-test-network01/providers/Microsoft.Network/virtualNetworks/vnet-ct-test-network01 is currently not allowed. Click here for details
  }
}

// creation of Azure Databricks AccessConnector
resource accessConnector 'Microsoft.Databricks/accessConnectors@2022-04-01-preview' = {
  name: dataBricksAccessConnectorName
  location: location
  tags: union({
      Name: dataBricksAccessConnectorName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// creation of azure databricks workspace (Private Workspace)
resource databricksWorkspace 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: databricksWorkspaceName
  location: location
  tags: union({
      Name: databricksWorkspaceName
    }, combineResourceTags)
  sku: {
    name: pricingTier
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', managedResourceGroupName)
    publicNetworkAccess: publicNetworkAccess
    requiredNsgRules: networkApproach[networkAccessApproach].requiredNsgRules
    parameters: {
      requireInfrastructureEncryption: {
        value: requireInfrastructureEncryption
      }
      enableNoPublicIp: {
        value: disablePublicIp
      }
      customVirtualNetworkId: networkApproach[networkAccessApproach].vnetId
      customPublicSubnetName: networkApproach[networkAccessApproach].customPublicSubnetName
      customPrivateSubnetName: networkApproach[networkAccessApproach].customPrivateSubnetName
    }
  }
}

// creation of databricks private endpoint for ui_api
resource ui_api_privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: databricksPrivateEndpointName_ui_api
  location: location
  tags: union({
      Name: databricksPrivateEndpointName_ui_api
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: databricksPrivateEndpointName_ui_api
        properties: {
          privateLinkServiceId: databricksWorkspace.id
          groupIds: [
            ui_api_groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: ui_apiCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

// creation of databricks private endpoint for browser authentication
resource browser_auth_privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: databricksPrivateEndpointName_browser_auth
  location: location
  tags: union({
      Name: databricksPrivateEndpointName_browser_auth
    }, combineResourceTags)
  dependsOn: [
    ui_api_privateEndpoint
  ]
  properties: {
    privateLinkServiceConnections: [
      {
        name: databricksPrivateEndpointName_browser_auth
        properties: {
          privateLinkServiceId: databricksWorkspace.id
          groupIds: [
            browser_auth_groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: browser_authCustomNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource databricksPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: databricksPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: databricksPrivateDnsZoneName
    }, combineResourceTags)
}

resource databricksPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: databricksPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource databricks_ui_api_PvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: databricks_ui_api_PvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? databricksPrivateDnsZone.id : existingDatabricksPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    ui_api_privateEndpoint
  ]
}

resource databricks_browser_auth_PvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: databricks_browser_auth_PvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? databricksPrivateDnsZone.id : existingDatabricksPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    browser_auth_privateEndpoint, databricks_ui_api_PvtEndpointDnsGroup
  ]
}
