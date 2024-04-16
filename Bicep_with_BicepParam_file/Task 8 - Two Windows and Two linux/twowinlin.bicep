//param vmName string
param location string
param vmSize string
param publicIpSku string
param publicIPAllocationMethod string 
//param publicIpName string 
param adminUsername string
//param publicIpName2 string
param addressPrefix array
param subnet1prefix array
param subnet2prefix array

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
param count int





var networkSecurityGroupName = 'default-NSG'





resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-3389'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRange: '3389'
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

resource subnetw 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for i in range(0, count): {
  name: 'subnetw${i}'
  parent: virtualNetwork[0]
  properties: {
    addressPrefix: subnet1prefix[i]
    networkSecurityGroup: {
       id: networkSecurityGroup.id
    }
  }
  
}]
resource subnetl 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for i in range(0, count): {
  name: 'subnetl${i}'
  parent: virtualNetwork[1]
  properties: {
    addressPrefix: subnet2prefix[i]
    networkSecurityGroup: {
       id: networkSecuritylinux.id
    }
  }
  
}]

resource nicw 'Microsoft.Network/networkInterfaces@2023-04-01' =[for i in range(0,count): {
  name: 'nicw${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: subnetw[i].id 
           
          }
        }
      }
    ]
  }
}]

resource nicl 'Microsoft.Network/networkInterfaces@2023-04-01' =[for i in range(0,count): {
  name: 'nicl${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          
          subnet: {
            id: subnetl[i].id 
           
          }
        }
      }
    ]
  }
}]




resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, count): {
  name: 'vmw${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'vmw${i}'
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
          id: nicw[i].id
        }
      ]
    }
    
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}]

//linux vm

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

resource networkSecuritylinux 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'nsglinux'
  location: location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}


resource vmlinux 'Microsoft.Compute/virtualMachines@2021-11-01' = [for i in range(0,count): {
  name: 'vml${i}'
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
          id: nicl[i].id
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
