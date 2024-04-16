targetScope = 'subscription'

@description('Email address to send Defender security alert emails to')
param securityAlertEmail string

@description('Azure RBAC roles to send security alert notifications to')
param securityAlertRoles array = []

@description('Workspace VMs will send logs used by Defender to generate alerts')
param defenderWorkspaceId string

@description('Cloud Security Posture Management plan')
@allowed([
  'Free'
  'Standard'
])
param cloudPostureDefenderTier string = 'Standard'

@description('Cloud Security Posture Management enable agentless vulnerability scanning of VMs')
param cloudPostureAgentlessVmScanning bool = true

@description('Cloud Workload Protection plan for Servers')
@allowed([
  'Free'
  'Standard'
])
param virtualMachinesDefenderTier string = 'Standard'

@description('Cloud Workload Protection pricing tier for Servers')
@allowed([
  'P1'
  'P2'
])
param virtualMachinesDefenderSubPlan string = 'P2'

@description('Cloud Workload Protection plan for Servers agentless vulnerability scanning')
param virtualMachinesDefenderAgentlessVmScanning bool = true

@description('Cloud Workload Protection plan for App Services')
@allowed([
  'Free'
  'Standard'
])
param appServicesDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for SQL PaaS Servers')
@allowed([
  'Free'
  'Standard'
])
param sqlServersDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for SQL Server VMs')
@allowed([
  'Free'
  'Standard'
])
param sqlServerVirtualMachinesDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Open Source Relational DBs')
@allowed([
  'Free'
  'Standard'
])
param openSourceRelationalDatabasesDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Cosmos DB')
@allowed([
  'Free'
  'Standard'
])
param cosmosDbsDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Storage')
@allowed([
  'Free'
  'Standard'
])
param storageAccountsDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Storage pricing tier')
@allowed([
  'PerTransaction'
  'DefenderForStorageV2'
])
param storageAccountsDefenderSubPlan string = 'DefenderForStorageV2'

@description('Cloud Workload Protection plan for Containers')
@allowed([
  'Free'
  'Standard'
])
param containersDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Key Vault')
@allowed([
  'Free'
  'Standard'
])
param keyVaultsDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Key Vault pricing tier')
param keyVaultsDefenderSubPlan string = 'PerKeyVault'

@description('Cloud Workload Protection plan for DNS')
@allowed([
  'Free'
  'Standard'
])
param dnsDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Resource Manager')
@allowed([
  'Free'
  'Standard'
])
param armDefenderTier string = 'Standard'

@description('Cloud Workload Protection plan for Resource Manager pricing tier')
param armDefenderSubPlan string = 'PerSubscription'

@description('Cloud Workload Protection plan for API')
@allowed([
  'Free'
  'Standard'
])
param apiDefenderTier string = 'Standard'

@description('Cloud Security Posture Management enable sensitive data discovery')
var cloudPostureSensitiveDataDiscovery = true

@description('Cloud Security Posture Management enable vulnerability assessments on container registries')
var cloudPostureContainerRegistriesVulnerabilityAssessments = true

@description('Cloud Security Posture Management enable agentless discovery of containers running in Kubernetes')
var cloudPostureAgentlessDiscoveryForKubernetes = true

@description('Cloud Workload Protection plan for Containers enable vulnerability assessments on container registries')
var containersDefenderContainerRegistriesVulnerabilityAssessments = true

@description('Cloud Workload Protection plan for Containers enable agentless discovery of containers running in Kubernetes')
var containersDefenderAgentlessDiscoveryForKubernetes = true

@description('Cloud Workload Protection plan for Storage enable malware scanning')
var storageAccountsDefenderOnUploadMalwareScanning = true

@description('Minimum severity to send security alerts for')
var securityAlertMinimalSeverity = 'Medium'

@description('Cloud Workload Protection plan for Storage enable sensitive data discovery')
var storageAccountsDefenderSensitiveDataDiscovery = true

resource subDefenderApi 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'api'
  properties: {
    pricingTier: apiDefenderTier
  }
}

resource subDefenderAppServices 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'appServices'
  properties: {
    pricingTier: appServicesDefenderTier
  }
  dependsOn: [ subDefenderApi ]
}

resource subDefenderArm 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'arm'
  properties: {
    pricingTier: armDefenderTier
    subPlan: armDefenderSubPlan
  }
  dependsOn: [ subDefenderAppServices ]
}

resource subDefenderCloudPosture 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'cloudPosture'
  properties: {
    pricingTier: cloudPostureDefenderTier
    extensions: cloudPostureDefenderTier == 'Free' ? [] : [
      {
        name: 'SensitiveDataDiscovery'
        isEnabled: string(cloudPostureSensitiveDataDiscovery)
      }
      {
        name: 'ContainerRegistriesVulnerabilityAssessments'
        isEnabled: string(cloudPostureContainerRegistriesVulnerabilityAssessments)
      }
      {
        name: 'AgentlessDiscoveryForKubernetes'
        isEnabled: string(cloudPostureAgentlessDiscoveryForKubernetes)
      }
      {
        name: 'AgentlessVmScanning'
        isEnabled: string(cloudPostureAgentlessVmScanning)
        exclusionTags: []
      }
    ]
  }
  dependsOn: [ subDefenderArm ]
}

resource subDefenderContainers 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'containers'
  properties: {
    pricingTier: containersDefenderTier
    extensions: containersDefenderTier == 'Free' ? [] : [
      {
        name: 'ContainerRegistriesVulnerabilityAssessments'
        isEnabled: string(containersDefenderContainerRegistriesVulnerabilityAssessments)
      }
      {
        name: 'AgentlessDiscoveryForKubernetes'
        isEnabled: string(containersDefenderAgentlessDiscoveryForKubernetes)
      }
    ]
  }
  dependsOn: [ subDefenderCloudPosture ]
}

resource subDefenderCosmosDbs 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'cosmosDbs'
  properties: {
    pricingTier: cosmosDbsDefenderTier
  }
  dependsOn: [ subDefenderContainers ]
}

resource subDefenderDns 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'dns'
  properties: {
    pricingTier: dnsDefenderTier
  }
  dependsOn: [ subDefenderCosmosDbs ]
}

resource subDefenderKeyVaults 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'keyVaults'
  properties: {
    pricingTier: keyVaultsDefenderTier
    subPlan: keyVaultsDefenderSubPlan
  }
  dependsOn: [ subDefenderDns ]
}

resource subDefenderOpenSourceRelationalDatabases 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'openSourceRelationalDatabases'
  properties: {
    pricingTier: openSourceRelationalDatabasesDefenderTier
  }

  dependsOn: [ subDefenderKeyVaults ]
}

resource subDefenderStorageAccounts 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'storageAccounts'
  properties: {
    pricingTier: storageAccountsDefenderTier
    subPlan: storageAccountsDefenderSubPlan
    extensions: storageAccountsDefenderTier == 'Free' ? [] : [
      {
        name: 'OnUploadMalwareScanning'
        isEnabled: string(storageAccountsDefenderOnUploadMalwareScanning)
        additionalExtensionProperties: {
          CapGBPerMonthPerStorageAccount: 5000
        }
      }
      {
        name: 'SensitiveDataDiscovery'
        isEnabled: string(storageAccountsDefenderSensitiveDataDiscovery)
      }
    ]
  }

  dependsOn: [ subDefenderOpenSourceRelationalDatabases ]
}

resource subDefenderSqlServers 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'sqlServers'
  properties: {
    pricingTier: sqlServersDefenderTier
  }
  dependsOn: [ subDefenderStorageAccounts ]
}

resource subDefenderSqlServerVirtualMachines 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'sqlServerVirtualMachines'
  properties: {
    pricingTier: sqlServerVirtualMachinesDefenderTier
  }
  dependsOn: [ subDefenderSqlServers ]
}

resource subDefenderVirtualMachines 'Microsoft.Security/pricings@2023-01-01' = {
  name: 'virtualMachines'
  properties: {
    pricingTier: virtualMachinesDefenderTier
    subPlan: virtualMachinesDefenderSubPlan
    extensions: virtualMachinesDefenderTier == 'Free' ? [] : [
      {
        name: 'MdeDesignatedSubscription'
        isEnabled: 'False'
      }
      {
        name: 'AgentlessVmScanning'
        isEnabled: string(virtualMachinesDefenderAgentlessVmScanning)
      }
    ]
  }
  dependsOn: [ subDefenderSqlServerVirtualMachines ]
}

resource subDefenderContacts 'Microsoft.Security/securityContacts@2020-01-01-preview' = {
  name: 'default'
  properties: {
    emails: securityAlertEmail
    alertNotifications: {
      state: 'On'
      minimalSeverity: securityAlertMinimalSeverity
    }
    notificationsByRole: {
      state: 'On'
      roles: securityAlertRoles
    }
  }
}

resource subDefenderAutoProvision 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    autoProvision: 'On'
  }
}

resource subDefenderWorkspace 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = if (!empty(defenderWorkspaceId)) {
  name: 'default'
  properties: {
    scope: subscription().id
    workspaceId: defenderWorkspaceId
  }
}
