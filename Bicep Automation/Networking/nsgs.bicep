// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Enable Diagnostics Setting for all Azure Resources')
param enableDiagnosticSetting bool
@description('Log Analytics Workspace Resource ID')
param workspaceId string
@description('Retention Policy Day for All Logs that will stored in Log Analytics Workspace')
param retentionPolicyDays int
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string
@description('Create Windows or Linux Virtual Machine as per the user choice')
@allowed([
  'Windows'
  'Linux'
])
param virtualMachineType string

// variables
var settingName = 'Send to Log Analytics Workspace'
var nsgName = [
  toLower('nsg-${projectCode}-${environment}-compute01')
  toLower('nsg-${projectCode}-${environment}-web01')
  toLower('nsg-${projectCode}-${environment}-data01')
  toLower('nsg-${projectCode}-${environment}-db01')
  toLower('nsg-${projectCode}-${environment}-aap01')
]
var windowNsgRules = {
  name: 'Allow-3389-RDP'
  properties: {
    priority: 500
    access: 'Allow'
    direction: 'Inbound'
    destinationPortRange: '3389'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
}
var linuxNsgRules = {
  name: 'Allow-22-SSH'
  properties: {
    priority: 500
    access: 'Allow'
    direction: 'Inbound'
    destinationPortRange: '22'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
  }
}

// creation of network securuty group
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = [for name in nsgName: {
  name: name
  location: location
  tags: union({
      Name: name
    }, combineResourceTags)
  properties: {
    securityRules: []
  }
}]

// adding securitty rules to Network Security Group
resource nsgRules 'Microsoft.Network/networkSecurityGroups/securityRules@2022-07-01' = if (networkAccessApproach == 'Public') {
  name: virtualMachineType == 'Windows' ? windowNsgRules.name : linuxNsgRules.name
  parent: networkSecurityGroup[0]
  properties: {
    priority: virtualMachineType == 'Windows' ? windowNsgRules.properties.priority : linuxNsgRules.properties.priority
    access: virtualMachineType == 'Windows' ? windowNsgRules.properties.access : linuxNsgRules.properties.access
    direction: virtualMachineType == 'Windows' ? windowNsgRules.properties.direction : linuxNsgRules.properties.direction
    destinationPortRange: virtualMachineType == 'Windows' ? windowNsgRules.properties.destinationPortRange : linuxNsgRules.properties.destinationPortRange
    protocol: virtualMachineType == 'Windows' ? windowNsgRules.properties.protocol : linuxNsgRules.properties.protocol
    sourcePortRange: virtualMachineType == 'Windows' ? windowNsgRules.properties.sourcePortRange : linuxNsgRules.properties.sourcePortRange
    sourceAddressPrefix: virtualMachineType == 'Windows' ? windowNsgRules.properties.sourceAddressPrefix : linuxNsgRules.properties.sourceAddressPrefix
    destinationAddressPrefix: virtualMachineType == 'Windows' ? windowNsgRules.properties.destinationAddressPrefix : linuxNsgRules.properties.destinationAddressPrefix
  }
}

// Diagnostics Setting inside Network Security Group
resource setting 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2021-05-01-preview' = [for name in nsgName: if (enableDiagnosticSetting) {
  name: '${name}/microsoft.insights/${settingName}'
  dependsOn: [
    networkSecurityGroup
  ]
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          days: retentionPolicyDays
          enabled: true
        }
      }
    ]
  }
}]

// output of network security groups used in subnet.bicep
output computeNsgId string = networkSecurityGroup[0].id
output webNsgId string = networkSecurityGroup[1].id
output dataNsgId string = networkSecurityGroup[2].id
output databricksNsgId string = networkSecurityGroup[3].id
output appNsgId string = networkSecurityGroup[4].id
