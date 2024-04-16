@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Allow public access from specific virtual networks and IP addresses')
param allowPulicAccessFromSelectedNetwork bool
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
@description('Cognitive Serivce Private DNS Zone Id')
param existingCognitiveServicePrivateDnsZoneId string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@allowed([
  'Training'
  'Prediction'
])
param customVisionType string
@description('Cognitive Service is already deployed in azure once and want to recover the service with the same name so set Restore "true" or by default set it as "false"')
@allowed([
  true
  false ])
param cognitiveServiceRestore bool

// parameter
@description('Data Subnet Id for Prviate Endpoint')
param subnetRef string

module formRecognizer 'formRecognizer.bicep' = {
  name: 'formRecognizer'
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    enableDiagnosticSetting: enableDiagnosticSetting
    networkAccessApproach: networkAccessApproach
    retentionPolicyDays: retentionPolicyDays
    networkArchitectureApproach: networkArchitectureApproach
    workspaceId: workspaceId
    vnetId: vnetId
    vnetName: vnetName
    subnetRef: subnetRef
    existingCognitiveServicePrivateDnsZoneId: existingCognitiveServicePrivateDnsZoneId
    cognitiveServiceRestore: cognitiveServiceRestore
  }
}

module customVision 'customVision.bicep' = {
  name: 'customVision'
  dependsOn: [
    formRecognizer
  ]
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    enableDiagnosticSetting: enableDiagnosticSetting
    networkAccessApproach: networkAccessApproach
    retentionPolicyDays: retentionPolicyDays
    workspaceId: workspaceId
    subnetRef: subnetRef
    existingCognitiveServicePrivateDnsZoneId: existingCognitiveServicePrivateDnsZoneId
    privateDnsZoneId: formRecognizer.outputs.privateDnsZoneId
    networkArchitectureApproach: networkArchitectureApproach
    customVisionType: customVisionType
    cognitiveServiceRestore: cognitiveServiceRestore
  }
}

module speech 'speechService.bicep' = {
  name: 'speech'
  dependsOn: [
    formRecognizer
  ]
  params: {
    environment: environment
    projectCode: projectCode
    combineResourceTags: combineResourceTags
    location: location
    allowPulicAccessFromSelectedNetwork: allowPulicAccessFromSelectedNetwork
    enableDiagnosticSetting: enableDiagnosticSetting
    networkAccessApproach: networkAccessApproach
    retentionPolicyDays: retentionPolicyDays
    workspaceId: workspaceId
    subnetRef: subnetRef
    existingCognitiveServicePrivateDnsZoneId: existingCognitiveServicePrivateDnsZoneId
    privateDnsZoneId: formRecognizer.outputs.privateDnsZoneId
    networkArchitectureApproach: networkArchitectureApproach
    cognitiveServiceRestore: cognitiveServiceRestore
  }
}
