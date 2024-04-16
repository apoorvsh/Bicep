param subnetprefix array
param addressPrefix string
param count int
param location string
param subnetname array 
param vmname array
param nicname array
param vnetname string
param vmSize string
param adminUsername string
param publicIpSku string
param publicIPAllocationMethod string
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



resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' =[ for i in range(0, count): {
  name: 'publicIp${i+1}'
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    
  }
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' =  {
  name: vnetname
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
  
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = [for i in range(0, count): {
  name:  subnetname[i]
  parent: virtualNetwork
  properties: {
     addressPrefix: subnetprefix[i]
     networkSecurityGroup: {
       id: i==0 ? webnsgID.id : i==1 ? appnsgID.id : dbnsgID.id
     }
  }
}]



resource webnsgID  'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'webnsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'allowrdp'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRanges: [
            '3389'
          ]
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
           
        }
      }
      
      {
        name:'denydb'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          priority: 100
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: subnetprefix[0]
          destinationAddressPrefix: subnetprefix[2]
        }
      }
    ]
  }
  
}

resource appnsgID 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'appnsg'
  location: location
  
  properties: {
    securityRules: [
      {
        name: 'allowrdp'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRanges: [
            '3389'
          ]
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name:'denyhttphttps'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          priority: 100
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges:  [
            '80'
            '443'
          ]
          sourceAddressPrefix: subnetprefix[1]
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
 
}

resource dbnsgID 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'dbnsg'
  location: location
  
  properties: {
    securityRules: [
      {
        name: 'allowrdp'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          destinationPortRanges: [
            '3389'
          ]
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name:'denyweb'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          priority: 100
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange:  '*'
          sourceAddressPrefix: subnetprefix[2]
          destinationAddressPrefix: subnetprefix[0]
        }
      }
      {
        name:'denyapp'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          priority: 101
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: subnetprefix[2]
          destinationAddressPrefix: subnetprefix[1]
        }
      }
      {
        name:'denyhttphttps'
        properties: {
          access: 'Deny'
          direction: 'Outbound'
          priority: 102
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          sourceAddressPrefix: subnetprefix[2]
          destinationAddressPrefix: '*'
        }
      }
      
    ]
    
  }
 
}




resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' =[for i in range(0,count): {
  name: nicname[i]
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i+1}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
             id: publicIp[i].id
          }
          subnet: {
            id:  subnet[i].id
          }
        }
      }
    ]
  }
}]

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, count): {
  name:  vmname[i]
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmname[i]
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
          id: nic[i].id
        }
      ]
    }
    
    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
}]

resource vmicmpv4enable 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = [for i in range(0, count): {
  name: 'vmicmpv4'
  location: location
  parent: vm[i]
  properties: {
    asyncExecution: false
    source: {
      script: '''
        netsh advfirewall firewall add rule name = "ICMP Allow incoming V4 echo request" protocol="icmpv4:8" dir=in action=allow  
      '''
    }
  }
}]
