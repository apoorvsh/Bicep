param wanname string
param location string


resource symbolicname 'Microsoft.Network/virtualWans@2023-05-01' = {
  name: wanname
  location: location
  properties: {
    
  }  
}
