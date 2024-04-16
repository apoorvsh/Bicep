targetScope = 'subscription'

//Global Parameter
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resource Tags')
param combineResourceTags object
@description('Location in which our Resources and Resources Groups will be deployed')
param location string = deployment().location
@description('Vnet Address Space')
param vnetAddressSpace string
@description('subnet address Prefix')
param subnetAddressPrefix string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Select your Organizational networking architecture approach')
@allowed([ 'Federated', 'Hub & Spoke' ])
param networkArchitectureApproach string
@description('User e-mail Id required to make Azure Active Directory admin in Azure SQL Server')
param sqlAdminUser string
@description('User object Id required to make Azure Active Directory admin in Azure SQL Server')
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
@description('Existing SQL Server Private DNS Zone')
param existingSqlServerPrivateDnsZoneId string
@description('User Name for login into SQL database, Dedicated SQL Pool')
@secure()
param sqlUserName string
@description('Password for login into SQL database, Dedicated SQL Pool ')
@secure()
param sqlPassword string

// variables
@description('Data Platform Resource Group Name')
var dataPlatformResourceGroupName = toLower('rg-${projectCode}-${environment}-dp01')

// creation of dataPlatform Resource group
resource dataPlatformResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: dataPlatformResourceGroupName
  location: location
  tags: union({
      Name: dataPlatformResourceGroupName
    }, combineResourceTags)
}

module sqlDatabase '../Sql Database/sqlDatabase.bicep' = {
  name: 'sqlDatabase'
  scope: dataPlatformResourceGroup
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    subnetAddressPrefix: subnetAddressPrefix
    vnetAddressSpace: vnetAddressSpace
    networkAccessApproach: networkAccessApproach
    networkArchitectureApproach: networkArchitectureApproach
    sqlAdminUser: sqlAdminUser
    sqlAdminSID: sqlAdminSID
    existingSqlServerPrivateDnsZoneId: existingSqlServerPrivateDnsZoneId
    sqlDatabasePerformanceModel: sqlDatabasePerformanceModel
    requestedBackupStorageRedundancySqlServer: requestedBackupStorageRedundancySqlServer
    sqlUserName: sqlUserName
    adminPassword: sqlPassword

  }
}
