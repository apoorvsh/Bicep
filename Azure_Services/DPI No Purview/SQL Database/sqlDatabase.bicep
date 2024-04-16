//Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description(' User Name to login into SQL Server')
@secure()
param sqlUserName string
@description('Password to login into SQL Server')
@secure()
param adminPassword string
@description('User e-mail Id required to make Azure Active Directory admin in Sql Admin')
param sqlAdminUser string
@description('User object Id required to make Azure Active Directory admin in Sql Admin')
param sqlAdminSID string
@description('SQL Database Performance Model')
@allowed([
  'Basic'
  'Standard'
  'Premium'
  'GeneralPurpose'
])
param sqlDatabasePerformanceModel string
@description('Redundancy for SQL Database')
@allowed([
  'Geo'
  'GeoZone'
  'Local'
  'Zone'
])
param requestedBackupStorageRedundancySqlServer string
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
@description('Existing SQL Server Private DNS Zone')
param existingSqlServerPrivateDnsZoneId string
// parameter
@description('Getting Resource Id of Data Subnet for SQL Private Endpoint')
param subnetRef string

// variables
@description('The name of the SQL logical server.')
var sqlServerName = toLower('db-${projectCode}-${environment}-dp03')
@description('The name of the SQL Database.')
var sqlDbName = toLower('db-${projectCode}-${environment}-dp03')
@description('SQL Server Private Endpoint Name')
var sqlServerPrivateEndpointName = toLower('pep-${projectCode}-${environment}-db01')
@description('Network Interface Name for SQL Database Private Endpoint')
var customNetworkInterfaceName = toLower('nic${projectCode}${environment}db01')
@description('Target Sub Resource of SQL Server')
var groupId = 'sqlServer'
@description('SQL Database Network Access')
var publicNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
@description('Restrict Outbound Network Access')
var restrictOutboundNetworkAccess = networkAccessApproach == 'Private' ? 'Disabled' : 'Enabled'
@description('Allow Azure AD Only Authentication')
var azureADOnlyAuthentication = false
@description('SQL Database Zone redundant')
var zoneRedundant = false
var sqlPrivateDnsZoneName = 'privatelink${az.environment().suffixes.sqlServerHostname}'
var sqlPvtEndpointDnsGroupName = '${sqlServerPrivateEndpointName}/mydnsgroupname'
var sqlSkuConfig = {
  Basic: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  Standard: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 10
  }
  Premium: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 125
  }
  GeneralPurpose: {
    name: 'GP_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 2
  }
}
var sqlRedundancyConfig = {
  Local: {
    name: 'Local'
  }
  GeoZone: {
    name: 'GeoZone'
  }
  Zone: {
    name: 'Zone'
  }
  Geo: {
    name: 'Geo'
  }
}
var advancedThreatProtectionSettings = networkAccessApproach == 'Private' ? 'Enabled' : 'Disabled'

// creation of sql server
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: union({
      Name: sqlServerName
    }, combineResourceTags)
  properties: {
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    administratorLogin: sqlUserName
    administratorLoginPassword: adminPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      login: sqlAdminUser
      sid: sqlAdminSID
      tenantId: subscription().tenantId
      azureADOnlyAuthentication: azureADOnlyAuthentication
    }
  }
}

// creation of sql database
resource sqlDB 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  parent: sqlServer
  name: sqlDbName
  location: location
  tags: union({
      Name: sqlDbName
    }, combineResourceTags)
  sku: sqlSkuConfig[sqlDatabasePerformanceModel]
  properties: {
    requestedBackupStorageRedundancy: sqlRedundancyConfig[requestedBackupStorageRedundancySqlServer].name
    zoneRedundant: zoneRedundant
  }
}

// creation of sql server private endpoint
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (networkAccessApproach == 'Private') {
  name: sqlServerPrivateEndpointName
  location: location
  tags: union({
      Name: sqlServerPrivateEndpointName
    }, combineResourceTags)
  properties: {
    privateLinkServiceConnections: [
      {
        name: sqlServerPrivateEndpointName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
    customNetworkInterfaceName: customNetworkInterfaceName
    subnet: {
      id: subnetRef
    }
  }
}

resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  name: sqlPrivateDnsZoneName
  location: 'global'
  properties: {}
  tags: union({
      Name: sqlPrivateDnsZoneName
    }, combineResourceTags)
}

resource sqlPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (networkArchitectureApproach == 'Federated' && networkAccessApproach == 'Private') {
  parent: sqlPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource sqlPvtEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if (networkAccessApproach == 'Private') {
  name: sqlPvtEndpointDnsGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: networkArchitectureApproach == 'Federated' ? sqlPrivateDnsZone.id : existingSqlServerPrivateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    sqlPrivateEndpoint
  ]
}

resource advancedThreatProtection 'Microsoft.Sql/servers/advancedThreatProtectionSettings@2022-05-01-preview' = {
  name: 'Default'
  parent: sqlServer
  properties: {
    state: advancedThreatProtectionSettings
  }
}
