param routeTableName string
param routeTableLocation string

resource routeTable 'Microsoft.Network/routeTables@2023-04-01' = {
  name: routeTableName
  location: routeTableLocation
  properties: {
    routes: [
      
    ]
  }
}


