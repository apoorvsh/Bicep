targetScope = 'subscription'

@description('Location for the all the Azure Services')
param location string = deployment().location
@description('Tags for the resoruces')
param resourceTags object
@description('Resource Group Name')
param resourceGroupName string
param environment string
param domainName string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Email address to send Defender security alert emails to')
param securityAlertEmail string = ''

var domain = toLower(domainName)
var locationMap = {
  northeurope: 'ne'
  centralindia: 'in'
  westeurope: 'we'
  eastus2: 'eu2'
}

var resourceNames = {
  workSpaceName: toLower('${environment}-${locationMap[location]}-${domain}-log01')
}

module resourceGroup_Creation '../../../Modules/Resource Group/resource_group.mod.bicep' = {
  name: resourceGroupName
  params: {
    location: location
    name: resourceGroupName
    resourceTags: resourceTags
  }
}

module log_Analytic_Workspace '../../../Modules/Monitoring/log_analytic.mod.bicep' = {
  name: 'deploy-logAnalyticWorkspace'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.workSpaceName
    location: location
    resourceTags: resourceTags
  }
}

module log_Analytic_Workspace_Diagnostic '../../../Modules/Monitoring/diagnostic.mod.bicep' = if (enableDiagnosticSetting) {
  name: 'deploy-logAnalyticWorkspace-diagnostic'
  scope: resourceGroup(resourceGroup_Creation.name)
  params: {
    name: resourceNames.workSpaceName
    workspaceId: log_Analytic_Workspace.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    log_Analytic_Workspace
  ]
}

module activity_Log_Alert_Subscription '../../../Modules/Monitoring/activity_log.mod.bicep' = {
  name: 'deploy-activityLogAlert-subscription'
  params: {
    workspaceId: log_Analytic_Workspace.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    log_Analytic_Workspace
  ]
}

module defender_For_Cloud '../../../Modules/Monitoring/defender_for_cloud.mod.bicep' = {
  name: 'deploy-defenderForCloud'
  params: {
    defenderWorkspaceId: log_Analytic_Workspace.outputs.logAnalyticsWorkspaceId
    securityAlertEmail: securityAlertEmail
  }
  dependsOn: [
    log_Analytic_Workspace
  ]
}
