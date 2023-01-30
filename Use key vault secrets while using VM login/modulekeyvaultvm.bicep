param keyVaultName string
param ipConfigName string
param nicName string
param nsgAccess string
param nsgDestinationAddressPrefix string
param nsgDestinationPortRange string
param nsgDirection string
param nsgName string
param nsgPriority int
param nsgProtocol string
param nsgRuleName string
param nsgSourceAddressPrefix string
param nsgSourcePortRange string
param windowNsgTagName object
param osDiskCaching string
param osDiskCreateOption string
param osDiskName string
param osProfileComputerName string
param privateIpAllocationMethod string
param publicIpAllocationMethod string
param publicIpName string
param storageProfileOffer string
param storageProfilePublisher string
param storageProfileSku string
param storageProfileVersion string
param subnetAddress string
param subnetName string
param vnetName string
param vnetAddress string
param vnetTagName object
param windowNicTagName object
param windowPulicIpTagName object
param windowVmName string
param windowVmSize string
param windowVmTagName object

resource keyVault'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup('spokerg')
}

module  windowsVM './WindowVmKeyVault.bicep' = {
  name: 'getsecrets' 
  scope: resourceGroup('spokerg')
  params: {
     windowAdminUserName: keyVault.getSecret('VmUserName')
     windowAdminPassword: keyVault.getSecret('VmPassword')
     ipConfigName: ipConfigName
     nicName: nicName
     nsgAccess: nsgAccess
     nsgDestinationAddressPrefix: nsgDestinationAddressPrefix
     nsgDestinationPortRange: nsgDestinationPortRange
     nsgDirection: nsgDirection
     nsgName: nsgName
     nsgPriority: nsgPriority
     nsgProtocol: nsgProtocol
     nsgRuleName:  nsgRuleName
     nsgSourceAddressPrefix: nsgSourceAddressPrefix
     nsgSourcePortRange: nsgSourcePortRange
     windowNsgTagName: windowNsgTagName
     osDiskCaching: osDiskCaching
     osDiskCreateOption: osDiskCreateOption
     osDiskName: osDiskName
     osProfileComputerName: osProfileComputerName
     privateIpAllocationMethod: privateIpAllocationMethod
     publicIpAllocationMethod: publicIpAllocationMethod
     publicIpName: publicIpName
     storageProfileOffer: storageProfileOffer
     storageProfilePublisher: storageProfilePublisher
     storageProfileSku: storageProfileSku
     storageProfileVersion: storageProfileVersion
     subnetAddress: subnetAddress
     subnetName: subnetName
     vnetName: vnetName
     vnetAddress: vnetAddress
     vnetTagName: vnetTagName
     windowNicTagName: windowNicTagName
     windowPulicIpTagName: windowPulicIpTagName
     windowVmName: windowVmName
     windowVmSize: windowVmSize
     windowVmTagName: windowVmTagName
    }
}
