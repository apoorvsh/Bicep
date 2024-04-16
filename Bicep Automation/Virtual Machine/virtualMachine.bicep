// Global parameters
@description('Project Code')
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string
@description('Create Windows or Linux Virtual Machine as per the user choice')
@allowed([
  'Windows'
  'Linux'
])
param virtualMachineType string
@description('User Name for login into Jump Server VM')
@secure()
param vmUserName string
@description('Password for login into Jump Server VM')
@secure()
param vmPassword string
@description('Network Access Public or Private')
@allowed([ 'Public', 'Private' ])
param networkAccessApproach string

// parameter
@description('Getting Resource Id of compute Subnet for Nic Card')
param subnetRef string

// variables
@description('Virtual Machine Public IP name')
var publicIpConfig = [
  {
    name: virtualMachineType == 'Windows' ? toLower('pub-ip-${projectCode}-${environment}-window01') : toLower('pub-ip-${projectCode}-${environment}-linux01')
    //dnsLabelPrefix: virtualMachineType == 'Windows' ? toLower('${projectCode}-${environment}-${uniqueString(resourceGroup().id)}-window01') : toLower('${projectCode}-${environment}-${uniqueString(resourceGroup().id)}-linux01')
  }
  /* {
    name: virtualMachineType == 'Windows' ? toLower('pub-ip-${projectCode}-${environment}-window02') : toLower('pub-ip-${projectCode}-${environment}-linux02')
    //dnsLabelPrefix: virtualMachineType == 'Windows' ? toLower('${projectCode}-${environment}-${uniqueString(resourceGroup().id)}-window02') : toLower('${projectCode}-${environment}-${uniqueString(resourceGroup().id)}-linux02')
  }*/
]
@description('Virtual Machine Network Interface card name')
var nicConfig = [
  {
    name: virtualMachineType == 'Windows' ? toLower('nic${projectCode}${environment}window01') : toLower('nic${projectCode}${environment}linux01')
  }
  /* {
    name: virtualMachineType == 'Windows' ? toLower('nic${projectCode}${environment}window02') : toLower('nic${projectCode}${environment}linux02')
  }*/
]
@description('Virtual Machines Configurations')
var vmConfig = [
  {
    vmName: virtualMachineType == 'Windows' ? toLower('vm${projectCode}${environment}window01') : toLower('vm${projectCode}${environment}linux01')
    osDiskName: virtualMachineType == 'Windows' ? toLower('osDisk-${projectCode}-${environment}-window01') : toLower('osDisk${projectCode}-${environment}-linux01')
  }
  /*{
    vmName: virtualMachineType == 'Windows' ? toLower('vm${projectCode}${environment}window02') : toLower('vm${projectCode}${environment}linux02')
    osDiskName: virtualMachineType == 'Windows' ? toLower('osDisk-${projectCode}-${environment}-window02') : toLower('osDisk${projectCode}-${environment}-linux02')
  }*/
]
@description('Allocation method for the Public IP used to access the Virtual Machine.')
/*@allowed([
  'Dynamic'
  'Static'
])*/
var publicIPAllocationMethod = 'Static'

@description('SKU for the Public IP used to access the Virtual Machine.')
/*@allowed([
  'Basic'
  'Standard'
])*/
var publicIpSku = 'Standard'
@description('Private IP allocation method for NIC')
var privateIpAllocationMethod = 'Dynamic'
@description('Virtual Machine Size')
var vmSize = 'Standard_D2s_v3'
@description('Virtual Machine OS Disk type')
var storageAccountType = 'StandardSSD_LRS'
@description('Virtual Machine computer Name')
var computerName = virtualMachineType == 'Windows' ? 'window-vm' : 'linux-vm'
@description('Virtual Machine OS disk Create Option')
var osDiskCreateOption = 'FromImage'
@description('Virtual Machine availabilty Zone')
var availabilityZones = '1'
var imageReference = virtualMachineType == 'Windows' ? windowImageReference : linuxImageReference
var linuxImageReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18_04-lts-gen2'
  version: 'latest'
}
/*@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])*/
var windowImageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-datacenter-gensecond'
  version: 'latest'
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = [for (config, i) in publicIpConfig: if (networkAccessApproach == 'Public') {
  name: config.name
  location: location
  tags: union({
      Name: config.name
    }, combineResourceTags)
  sku: {
    name: publicIpSku
  }
  zones: [
    availabilityZones
  ]
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    /*dnsSettings: {
      domainNameLabel: config.dnsLabelPrefix
    }*/
  }
}]

// creation of network interface card
resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for (config, i) in nicConfig: {
  name: config.name
  location: location
  dependsOn: [
    publicIp
  ]
  tags: union({
      Name: config.name
    }, combineResourceTags)
  properties: {
    ipConfigurations: [
      {
        name: 'ip-config'
        properties: {
          privateIPAllocationMethod: privateIpAllocationMethod
          publicIPAddress: networkAccessApproach == 'Public' ? json('{"id": "${publicIp[i].id}"}') : null
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
}]

// creation of window virtual machine
resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-12-01' = [for (config, i) in vmConfig: {
  name: config.vmName
  location: location
  dependsOn: [
    networkInterface, publicIp
  ]
  tags: union({
      Name: config.vmName
    }, combineResourceTags)
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: vmUserName
      adminPassword: vmPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: config.osDiskName
        createOption: osDiskCreateOption
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface[i].id
        }
      ]
    }
  }
  zones: [
    availabilityZones
  ]
}]
