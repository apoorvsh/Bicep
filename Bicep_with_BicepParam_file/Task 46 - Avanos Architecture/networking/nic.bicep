param values object 
param publicid string
param subnetid string






resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: values.nicName
  location: values.location
  properties: {
    ipConfigurations: [
       {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
             id: publicid
          } 
          subnet: {
            id: subnetid
          }
        }
       }
    ]
  }
}

output nicid string = nic.id
