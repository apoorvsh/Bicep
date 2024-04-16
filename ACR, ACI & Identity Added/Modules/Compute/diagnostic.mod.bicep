@description('Virtual Machine Name')
param name string
@description('Resource Location')
param location string
@description('Tags for the resources')
param resourceTags object
@description('Resource Id of the storage account that will have the Azure Activity log sent to')
param storageAccountResourceId string = ''
@description('The name of an existing storage account to which diagnostics data will be transferred.')
param existingdiagnosticsStorageAccountName string

resource existingVirtualMachine 'Microsoft.Compute/virtualMachines@2023-07-01' existing = {
  name: name
}

var accountid = storageAccountResourceId

resource vmName_Microsoft_Insights_VMDiagnosticsSettings 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  parent: existingVirtualMachine
  name: 'Microsoft.Insights.VMDiagnosticsSettings'
  location: location
  tags: resourceTags
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'IaaSDiagnostics'
    typeHandlerVersion: '1.5' // Updated version
    autoUpgradeMinorVersion: true
    settings: {
      StorageAccount: existingdiagnosticsStorageAccountName
      PublicConfig: {
        WadCfg: {
          DiagnosticMonitorConfiguration: {
            overallQuotaInMB: 10000
            DiagnosticInfrastructureLogs: {
              scheduledTransferLogLevelFilter: 'Error'
            }
            PerformanceCounters: {
              scheduledTransferPeriod: 'PT1M'
              PerformanceCounterConfiguration: [
                {
                  counterSpecifier: '\\Processor(_Total)\\% Processor Time'
                  sampleRate: 'PT3M'
                  unit: 'percent'
                }
              ]
            }
            WindowsEventLog: {
              scheduledTransferPeriod: 'PT1M'
              DataSource: [
                {
                  name: 'Application!*[System[(Level=1 or Level=2 or Level=3)]]'
                }
              ]
            }
          }
        }
        StorageAccount: existingdiagnosticsStorageAccountName
        StorageType: 'TableAndBlob'
      }
    }
    protectedSettings: {
      storageAccountName: existingdiagnosticsStorageAccountName
      storageAccountKey: listkeys(accountid, '2019-06-01').keys[0].value
      storageAccountEndPoint: 'https://${az.environment().suffixes.storage}'
    }
  }
}
