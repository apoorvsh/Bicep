@sys.description('Specifies the name of the Azure Machine Learning workspace.')
param workspaceName string
@allowed([
  'Default'
  'FeatureStore'
  'Hub'
  'Project'
])
param kind string = 'Default'
@sys.description('Specifies the sku, also referred as \'edition\' of the Azure Machine Learning workspace.')
@allowed([
  'Basic'
  'Enterprise'
])
param sku string = 'Basic'
@allowed([
  'Basic' 
  'Free'
  'Premium' 
  'Standard'
])
param tier string = 'Premium'
@sys.description('Specifies the location for all resources.')
param location string
@sys.description('Specifies the resource group name of the Azure Machine Learning workspace.')
param resourceGroupName string
@sys.description('Specifies the identity type of the Azure Machine Learning workspace.')
@allowed([
  'systemAssigned'
  'userAssigned'
])
param identityType string = 'systemAssigned'
@sys.description('Specifies the resource group of user assigned identity that represents the Azure Machine Learing workspace.')
param primaryUserAssignedIdentityResourceGroup string = resourceGroupName
@sys.description('Specifies the name of user assigned identity that represents the Azure Machine Learing workspace.')
param primaryUserAssignedIdentityName string = ''
@sys.description('Determines whether or not a new storage should be provisioned.')
@sys.description('Name of the storage account.')
param storageAccountName string
param storageAccountResourceGroupName string = resourceGroupName
@sys.description('Determines whether or not a new key vault should be provisioned.')
@sys.description('Name of the key vault.')
param keyVaultName string
param keyVaultResourceGroupName string = resourceGroupName
@sys.description('Name of ApplicationInsights.')
param applicationInsightsName string
param applicationInsightsResourceGroupName string = resourceGroupName
@sys.description('Determines whether or not a new container registry should be provisioned.')
@allowed([
  'new'
  'existing'
  'none'
])
param containerRegistryOption string = 'none'
@sys.description('The container registry bind to the workspace.')
param containerRegistryName string = 'cr${uniqueString(resourceGroupName, workspaceName)}'
param containerRegistryResourceGroupName string = resourceGroupName
param tagValues object
@sys.description('Specifies whether the workspace can be accessed by public networks or not.')
param publicNetworkAccess string = 'Enabled'
@sys.description('Determines ML Studio Workspace Outbound Access Method.')
@allowed([
  'AllowInternetOutbound'
  'AllowOnlyApprovedOutbound'
  'Disabled'
])
param mlStudioManagedNetworkMode string


var storageAccountId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${storageAccountResourceGroupName}/providers/Microsoft.Storage/storageAccounts/${storageAccountName}'
var keyVaultId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${keyVaultResourceGroupName}/providers/Microsoft.KeyVault/vaults/${keyVaultName}'
var containerRegistryId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${containerRegistryResourceGroupName}/providers/Microsoft.ContainerRegistry/registries/${containerRegistryName}'
var applicationInsightsId = '/subscriptions/${subscription().subscriptionId}/resourceGroups/${applicationInsightsResourceGroupName}/providers/microsoft.insights/components/${applicationInsightsName}'

var userAssignedIdentities = {
  '${primaryUserAssignedIdentity}': {}
}
var primaryUserAssignedIdentity = resourceId(primaryUserAssignedIdentityResourceGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', primaryUserAssignedIdentityName)

resource workspace 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  tags: tagValues
  name: workspaceName
  location: location
  kind: kind
  identity: {
    type: identityType
    userAssignedIdentities: ((identityType == 'userAssigned') ? userAssignedIdentities : null)
  }
  sku: {
    tier: tier
    name: sku
  }
  properties: {
    storageAccount: storageAccountId
    keyVault: keyVaultId
    applicationInsights:  applicationInsightsId
    containerRegistry: ((containerRegistryOption != 'none') ? containerRegistryId : null)
    primaryUserAssignedIdentity: ((identityType == 'userAssigned') ? primaryUserAssignedIdentity : null)
    publicNetworkAccess: publicNetworkAccess
    managedNetwork:{
      isolationMode:mlStudioManagedNetworkMode
      status:{
        status:'Inactive'
        sparkReady:false
      }
    }
  }
}
