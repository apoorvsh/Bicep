param vmName string
param location string
param vmSize string
param adminUsername string
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string
param OSVersion string 
param securityType string
param nicName string
param ipconfigname string
param privateIPAllocationMethod string
param nsgName string
param nsgLocation string
param subnetname string
param subnetprefix string
param vnetname string 
param addressprefix string 




resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetname
  location: location
  properties: {
     addressSpace: {
       addressPrefixes: [
        addressprefix
       ]
     }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetname
  parent: vnet
  properties: {
     addressPrefix: subnetprefix
     networkSecurityGroup: {
       id: resourceId('Microsoft.Network/networkSecurityGroups', nsgName)
     } 
       
  }
}


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: nsgLocation
  properties: {
    securityRules: [
      
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ipconfigname
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
             id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, subnetname)
          }
        }
      }
    ]
    
  }
   
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
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
           id: resourceId('Microsoft.Network/networkInterfaces',nicName)
        }
      ]
    }
    
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}
