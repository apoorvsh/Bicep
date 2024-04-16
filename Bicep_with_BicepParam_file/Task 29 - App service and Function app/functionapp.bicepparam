using './functionapp.bicep'

param name = 'hemangfuncapp'
param location = 'Central India'
param use32BitWorkerProcess = false
param ftpsState = 'FtpsOnly'
param storageAccountName = 'hemangstoragenew'
param linuxFxVersion = 'DOCKER|mcr.microsoft.com/azure-functions/dotnet:4-appservice-quickstart'
param sku = 'ElasticPremium'
param skuCode = 'EP1'
param applicationInsightsName = 'hemangfunc'
param dockerRegistryStartupCommand = ''
param hostingPlanName = 'ASP-HemangRG-8c18'

