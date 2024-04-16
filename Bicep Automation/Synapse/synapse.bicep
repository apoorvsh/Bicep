// Global paramters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('User Name for login into Synapse SQL')
@secure()
param sqlUserName string
@description('Password for login into Synpase SQL')
@secure()
param adminPassword string
@description('User e-mail Id required to make Azure Active Directory admin in azure Synapse')
param synapseWSAdminUser string
@description('User object Id required to make Azure Active Directory admin in azure Synapse')
param synapseWSAdminSID string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('Virtual Network ID for Virtual Network Link inside Private DNS Zone')
param vnetId string
@description('Virtual Network Name')
param vnetName string
@description('Existing Storage Account')
param storageAccountName string
@description('Contianer Created in azure Synapse')
param synapseFileSystemName string
@description('Existing Azure Synapse Dev Private DNS Zone')
param existingSynapseDevPrivateDnsZoneId string
@description('Existing Azure Synapse SQL On Demand Private DNS Zone')
param existingSynapseSqlPrivateDnsZoneId string
@description('Optional. The Apache Spark version.')
@allowed([
  '3.3'
  '3.2'
  '3.1'
])
param sparkVersion string
@description('Optional. The kind of nodes that the Spark Pool provides.')
@allowed([
  'MemoryOptimized'
  'HardwareAccelerated'
])
param sparkNodeSizeFamily string
@description('Optional. The level of compute power that each node in the Big Data pool has.')
@allowed([
  'Small'
  'Medium'
  'Large'
  'XLarge'
  'XXLarge'
])
param sparkNodeSize string
@description('Getting Resource Id of Data Subnet for synapse Private Endpoint')
param dataSubnetRef string
@description('Getting Resource Id of compute Subnet for Synapse Private Endpoint on Dev')
param computeSubnetRef string
@description('Existing ADLS Gen2 Resource Id')
param adlsGen2SilverStorageAccountRef string
@description('Synaspe Dedicated SQL Poll Sku Type')
@allowed([
  'DW100c'
  'DW400c'
  'DW1000c'
])
param dedicatedPoolSkuCapacity string
@description('Existing Azure Synapse Private Link Hub Private DNS Zone')
param existingSynapseLinkHubPrivateDnsZoneId string

// variables
@description('Azure Synapse Analytics WorkSpace Name')
var synapseName = toLower('synw${projectCode}${environment}dp01')
@description('Azure Synaspe SHIR Name')
var shirName = toLower('synw-${projectCode}-${environment}-shir01')
@description('Synapse Private Endpoint Name on Dev')
var devSynapsePrivateEndpointName = toLower('pep-${projectCode}-${environment}-dev01')
@description('Network Interface Name for Synapse Private Endpoint')
var devCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}dev01')
@description('Synapse Private Endpoint Name on Sql On Demand')
var sqlOnDemandSynapsePrivateEndpointName = toLower('pep-${projectCode}-${environment}-sqlod01')
@description('Network Interface Name for Synapse Private Endpoint')
var sqlOnDemandCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}sqlod01')
@description('Synapse Private Endpoint Name on Deidcated Sql Pool')
var dedicatedSqlPoolSynapsePrivateEndpointName = toLower('pep-${projectCode}-${environment}-sql01')
@description('Network Interface Name for Synapse Private Endpoint')
var dedicatedSqlPoolCustomNetworkInterfaceName = toLower('nic${projectCode}${environment}sql01')
@description('Dedicated SQL Pool Name for Azure Synapse Analytics Workspace')
var dedicatedSqlPoolName = toLower('synw${projectCode}${environment}dsp01')
@description('Target Sub Resource of Azure Synaspe Analytics')
var devGroupId = 'dev'
@description('Target Sub Resource of Azure Synaspe Analytics')
var sqlOnDemandGroupId = 'SqlOnDemand'
@description('Target Sub Resource of Azure Synaspe Analytics')
var dedicatedSqlPoolGroupId = 'Sql'
@description('Synapse Workspace Public Access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
@description('Silver Storage Account Url')
var adlsSilverPublicDNSZoneForwarder = az.environment().suffixes.storage
var silverStorageAccountUrl = toLower('https://${storageAccountName}.dfs.${adlsSilverPublicDNSZoneForwarder}')
@description('File System Name')
var fileSystemName = synapseFileSystemName
@description('Managed Virtual Network in azure synapse workspace')
var managedVirtualNetwork = 'default'
@description('Create Managed Private Endpoint')
var createManagedPrivateEndpoint = true
@description('Synapse Managed Resource Group Name')
var managedResourceGroupName = 'managed-rg-${synapseName}'
@description('Allow Data Exfiltration')
var preventDataExfiltration = true
@description('Allow Azure AD Only Authentication')
var azureADOnlyAuthentication = false
var sysDevPrivateDnsZoneName = 'privatelink.dev.azuresynapse.net'
var sysDevPvtEndpointDnsGroupName = '${devSynapsePrivateEndpointName}/mydnsgroupname'
var sysSqlPrivateDnsZoneName = 'privatelink.sql.azuresynapse.net'
var sysSqlOnDemandPvtEndpointDnsGroupName = '${sqlOnDemandSynapsePrivateEndpointName}/mydnsgroupname'
var sysSqlPvtEndpointDnsGroupName = '${dedicatedSqlPoolSynapsePrivateEndpointName}/mydnsgroupname'
@description('The SQL Database collation')
var collation = 'SQL_Latin1_General_CP1_CI_AS'
var skuCapacity = {
  DW100c: {
    capacity: 100
    name: 'DW100c'
    tier: 'DW100c'
  }
  DW400c: {
    capacity: 400
    name: 'DW400c'
    tier: 'DW400c'
  }
  DW1000c: {
    capacity: 1000
    name: 'DW1000c'
    tier: 'DW1000c'
  }
}
var settingName = 'Send to Log Analytics Workspace'

// creation of azure synapse workspace
resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: synapseName
  location: location
  tags: union({
      Name: synapseName
    }, combineResourceTags)
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    azureADOnlyAuthentication: azureADOnlyAuthentication
    managedVirtualNetwork: managedVirtualNetwork
    publicNetworkAccess: publicNetworkAccess
    managedResourceGroupName: managedResourceGroupName
    sqlAdministratorLogin: sqlUserName
    sqlAdministratorLoginPassword: adminPassword
    managedVirtualNetworkSettings: {
      preventDataExfiltration: preventDataExfiltration
      allowedAadTenantIdsForLinking: []
    }
    defaultDataLakeStorage: {
      accountUrl: silverStorageAccountUrl
      createManagedPrivateEndpoint: createManagedPrivateEndpoint
      filesystem: fileSystemName
      resourceId: adlsGen2SilverStorageAccountRef
    }
  }
}

// creation Self Hosted Integration Runtime in Azure Syanspe
resource shir 'Microsoft.Synapse/workspaces/integrationRuntimes@2021-06-01' = {
  name: shirName
  parent: synapse
  properties: {
    description: 'Self Hosted Integration Runtime'
    type: 'SelfHosted'
    typeProperties: {
      /* linkedInfo: {
        authorizationType: 'string'
        // For remaining properties, see LinkedIntegrationRuntimeType objects
      }*/
    }
  }
}
// creation of Azure Active Directory Admin in azure Synapse workaspace
// name cannot be change to another name
resource symbolicname 'Microsoft.Synapse/workspaces/administrators@2021-06-01' = {
  name: 'activeDirectory'
  parent: synapse
  properties: {
    administratorType: 'Synapse SQL Administrator'
    login: synapseWSAdminUser
    sid: synapseWSAdminSID
    tenantId: subscription().tenantId
  }
}

/*resource firewallRules 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = {
  name: 'string'
  parent: synapse
  properties: {
    endIpAddress: 'string'
    startIpAddress: 'string'
  }
}*/

// creation of synapse private endpint for dev
resource devPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: devSynapsePrivateEndpointName
  location: location
  tags: union({
      Name: devSynapsePrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: devSynapsePrivateEndpointName
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            devGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: devCustomNetworkInterfaceName
    subnet: {
      id: computeSubnetRef
    }
  }
}

resource sysDevPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: sysDevPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: sysDevPrivateDnsZoneName
    }, combineResourceTags)
}

resource sysDevPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: sysDevPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource sysDevPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: sysDevPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? sysDevPrivateDnsZone.id : existingSynapseDevPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    devPrivateEndpoint
  ]
}

// creation of synapse private endpoint for sqlOnDemand
resource sqlOnDemandPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: sqlOnDemandSynapsePrivateEndpointName
  location: location
  dependsOn: [
    devPrivateEndpoint
  ]
  tags: union({
      Name: sqlOnDemandSynapsePrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: sqlOnDemandSynapsePrivateEndpointName
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            sqlOnDemandGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: sqlOnDemandCustomNetworkInterfaceName
    subnet: {
      id: dataSubnetRef
    }
  }
}

resource sysSqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: sysSqlPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: sysSqlPrivateDnsZoneName
    }, combineResourceTags)
}

resource sysSqlPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: sysSqlPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource sysSqlOnDemandPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: sysSqlOnDemandPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? sysSqlPrivateDnsZone.id : existingSynapseSqlPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    sqlOnDemandPrivateEndpoint
  ]
}

// creation of dedicated sql pool in azure synapse workspace
resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name: dedicatedSqlPoolName
  location: location
  tags: union({
      Name: dedicatedSqlPoolName
    }, combineResourceTags)
  parent: synapse
  sku: skuCapacity[dedicatedPoolSkuCapacity]
  properties: {
    //publicNetworkAccess: 'Disabled'
    collation: collation
  }
}

// creation of synapse private endpoint for dedicated sql pool
resource dedicatedSqlPoolPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: dedicatedSqlPoolSynapsePrivateEndpointName
  dependsOn: [
    sqlOnDemandPrivateEndpoint
  ]
  location: location
  tags: union({
      Name: dedicatedSqlPoolSynapsePrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: dedicatedSqlPoolSynapsePrivateEndpointName
        properties: {
          privateLinkServiceId: synapse.id
          groupIds: [
            dedicatedSqlPoolGroupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: dedicatedSqlPoolCustomNetworkInterfaceName
    subnet: {
      id: dataSubnetRef
    }
  }
}

resource sysSqlPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: sysSqlPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? sysSqlPrivateDnsZone.id : existingSynapseSqlPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    dedicatedSqlPoolPrivateEndpoint
  ]
}

// Diagnostics Setting inside Azure Synapse Workspace
resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSetting) {
  name: settingName
  scope: synapse
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'SynapseRbacOperations'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'GatewayApiRequests'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'BuiltinSqlReqsEnded'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'IntegrationPipelineRuns'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'IntegrationActivityRuns'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'IntegrationTriggerRuns'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
      {
        category: 'SynapseLinkEvent'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}

module apacheSparkPool 'apacheSparkPool.bicep' = {
  name: 'apacheSparkPool'
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    synapseWorkspaceName: synapse.name
    sparkVersion: sparkVersion
    sparkNodeSizeFamily: sparkNodeSizeFamily
    sparkNodeSize: sparkNodeSize
  }
}

module synapsePrivateLinkHub 'synaspePrivateLinkHub.bicep' = {
  name: 'synaspePrivateLinkHub'
  params: {
    projectCode: projectCode
    environment: environment
    combineResourceTags: combineResourceTags
    location: location
    vnetId: vnetId
    vnetName: vnetName
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    dataSubnetRef: dataSubnetRef
    existingSynapseLinkHubPrivateDnsZoneId: existingSynapseLinkHubPrivateDnsZoneId
  }
}
// output the object ID of azure azure synapse workspace will use this in to add access policy in existing key vault
output synapseIdentityPrincipalId string = synapse.identity.principalId
