param values object 
param nicid string









var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: values.securityType
}


resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: values.vmName
  location: values.location
  properties: {
    hardwareProfile: {
      vmSize: values.vmSize
    }
    osProfile: {
      computerName: values.vmName
      adminUsername: values.adminUsername
      adminPassword: values.adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: values.publisher
        offer: 'WindowsServer'
        sku: values.OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicid
        }
      ]
    }
    
    securityProfile: ((values.securityType == 'Standard') ? securityProfileJson : null)
  }
}

output vmid string = vm.id
