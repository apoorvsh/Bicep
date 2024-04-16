param vnetName array
param addressPrefix array
param subnetName array
param subnetPrefix array
param location string
param count int
@allowed([
  'YES'
  'NO'
])
param conditionNsg string
@allowed([
  'YES'
  'NO'
])
param conditionRouteTable string


param routeTableName array


param nsgName array




resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01'  = [for i in range(0, count): {
   name: vnetName[i]
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
   name: subnetName[i]
   parent: vnet[i]
   properties: {
     addressPrefix: subnetPrefix[i]
     networkSecurityGroup: conditionNsg=='YES' ?  {
        id: nsg[i].id
     } : null
     routeTable: conditionRouteTable=='YES' ?  {
       id: routeTable[i].id
     } : null
   }  
}]





resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' =[ for i in range(0, count): if (conditionNsg=='YES') {
  name: nsgName[i]
  location: location
  properties: {
    securityRules: [
      
    ]
  }
}]




resource routeTable 'Microsoft.Network/routeTables@2023-04-01' = [for i in range(0, count): if(conditionRouteTable=='YES'){
  name: routeTableName[i]
  location: location
  properties: {
    routes: [
      
    ]
  }
}]


  



