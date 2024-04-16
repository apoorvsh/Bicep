param nicName string
param location string
param ipconfigname string
param privateIPAllocationMethod string





resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: ipconfigname
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
        }
      }
    ]
  }
}
