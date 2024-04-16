param location string
param vmSize string
param adminUsername string
param addressPrefix array
param nSGName string
param count int
param vmcount int
param niccount int
param subnetprefix array
@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}
param OSVersion string 
param securityType string




resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nSGName
  location: location
  properties: {
    securityRules: [
      {
        name: 'bothnsg'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRanges: [
            '3389'
            '22'
          ]
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = [ for i in range(0,count): {
  name: 'VNET${i+1}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix[i]
      ]
    }
  }
  
}]

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for i in range(0, count): {
  name: 'subnet${i+1}'
  parent: virtualNetwork[i]
  properties: {
     addressPrefix: subnetprefix[i]
     networkSecurityGroup: {
      id: networkSecurityGroup.id
     }
  }
}]

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' =[for i in range(0,niccount): {
  name: 'nic${i+1}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          applicationSecurityGroups: i<=3 ? asgvnet1.id : asgvnet2.id
          subnet: {
            id:  i<=3 ? subnet[0].id : subnet[1].id
           
          }
        }
      }
    ]
  }
}]

resource asgvnet1 'Microsoft.Network/applicationSecurityGroups@2019-11-01' = {
  name: 'asgvnet1'
  location: location
}

resource asgvnet2 'Microsoft.Network/applicationSecurityGroups@2019-11-01' = {
  name: 'asgvnet2'
  location: location
}



resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, vmcount): {
  name:  i<=1 ? 'vm${i+1}' : 'vm${i+3}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: i<=1 ? 'vm${i+1}' : 'vm${i+3}'
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
          id:  i<=1 ? nic[i].id : nic[i+2].id
        }
      ]
    }
    
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}]

var imageReference = {
  'Ubuntu-2004': {
    publisher: 'Canonical'
    offer: '0001-com-ubuntu-server-jammy'
    sku: '22_04-lts-gen2'
    version: 'latest'
  }
}

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${'linuxvm'}/.ssh/authorized_keys'
        keyData: 'Hemang@12345'
      }
    ]
  }
}

resource vmlinux 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(0,vmcount): {
  name:  i<=1 ? 'vm${i+3}' : 'vm${i+5}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: imageReference['Ubuntu-2004']
    }
    networkProfile: {
      networkInterfaces: [
        {
          id:  i<=1 ? nic[i+2].id : nic[i+3].id
        }
      ]
    }
    osProfile: {
      computerName: 'vml${i}'
      adminUsername: 'linuxvm'
      adminPassword: 'Hemang@12345'
      linuxConfiguration: (('password' == 'password') ? null : linuxConfiguration)
    }
    securityProfile: (('Standard' == 'Standard') ? securityProfileJson : null)
  }
}]
