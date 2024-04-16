param trafficname string
param location string
param endpointnames array
param targetnames array
param endpointlocations array
param endpointstatus string
param count int
param uniquedns string
param ttl int


resource trafficmanager 'Microsoft.Network/trafficmanagerprofiles@2022-04-01' = {
  name: trafficname
  location: location
  properties: {
   profileStatus: 'Enabled'
   trafficRoutingMethod: 'Performance'
   dnsConfig: {
     relativeName: uniquedns
     ttl: ttl 
   } 
   monitorConfig: {
    protocol: 'HTTPS'
    port: 443
    path: '/'
    expectedStatusCodeRanges: [
      {
        min: 200
        max: 202
      }
      {
        min: 301
        max: 302
      }
    ]
  }       
  }  
}

resource externalendpoint 'Microsoft.Network/trafficmanagerprofiles/ExternalEndpoints@2022-04-01' = [for i in range(0,count): {
  name:endpointnames[i]
  parent: trafficmanager
  properties: {
     target:  targetnames[i]
     endpointStatus: endpointstatus
     endpointLocation: endpointlocations[i]  
  }   
}]
  