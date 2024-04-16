using 'monitorServices.main.bicep'

param environment = 'ct' // dev
param domainName = 'ai'
param location = 'eastus2'
param resourceGroupName = 'dev-eu2-ai-monitor-rg'
param resourceTags = {
  Environment: 'dev'
  ApplicationName: 'PS Generator'
  BusinessUnit: 'Analytics'
  ApplicationPurpose: 'AI'
  ResourcePurpose: 'AI Core Services'
}
param securityAlertEmail = 'rsandoval@spyglassmtg.com'
param enableDiagnosticSetting = true
