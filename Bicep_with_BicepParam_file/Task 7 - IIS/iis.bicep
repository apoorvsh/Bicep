//param vmName string
param location string
param vmSize string
param publicIpSku string
param publicIPAllocationMethod string 
//param publicIpName string 
param adminUsername string
//param publicIpName2 string

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

/*var nicName = 'myVMNic'
var nicName2 = 'myVMNic2'
var addressPrefix = '10.5.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.5.0.0/18'*/
//var virtualNetworkName = 'MYVNET'
//var networkSecurityGroupName = 'default-NSG'


resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' =[ for i in range(0, count): {
  name: 'publicIp${i}'
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    
  }
}]



/*resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
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
}*/

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: 'VNET'
  
}

resource subnets 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: 'subnet'
  parent: virtualNetwork
  
  
}

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' =[for i in range(0,count): {
  name: 'nic${i}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp[i].id
          }
          subnet: {
            id: subnets.id
           // id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
        }
      }
    ]
  }
}]



resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, count): {
  name: 'vm${i}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'vm${i}'
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

resource vmFEIISEnabled 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = [for i in range(0, count): {
  name: 'vm-EnableIIS-Script'
  location: location
  parent: vm[i]
  properties: {
    asyncExecution: false
    source: {
      script: '''
        Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Remove-Item C:\\inetpub\\wwwroot\\iisstart.htm
        Add-Content -Path "C:\\inetpub\\wwwroot\\iisstart.htm" -Value $("Hello from " + $env:computername)  
      '''
    }
  }
}]
