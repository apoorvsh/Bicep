module vnet './vnett3.bicep' = {
  name: 'vnetmodule'
  params: {
    vnetName: 'modulevnet'
    vnetLocation: 'East US'
    subnetname: 'modulesubnet'
    subnetprefix: '10.2.0.0/18'
    vnetAddressPrefix: '10.2.0.0/16'
  }
}

module nsg './nsg.bicep' = {
  name: 'modulensg'
  params: {
    nsgLocation: 'East US'
    nsgName: 'nsgmodule'
  }
}

module routetable './routetable.bicep' ={
  name: 'moduleroute'
  params: {
    routeTableLocation: 'East US'
    routeTableName: 'routemodule'
  }
}
