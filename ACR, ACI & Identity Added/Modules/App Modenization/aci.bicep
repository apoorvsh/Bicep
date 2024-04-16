param instanceName string
param location string
param image string
param cpu int
param memory string
param osType string
param sku string
param ipPort int
param ipProtocol string
param ipType string
param subnetID string

resource aci 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: instanceName
  location: location 
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/367722a2-667e-40e3-ba4b-1078993dddf3/resourcegroups/ApoorvRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dockerid': {}
    }   
  } 
  properties: {
    imageRegistryCredentials: [
       {
        server: 'apoorvacr.azurecr.io'
        identity: '/subscriptions/367722a2-667e-40e3-ba4b-1078993dddf3/resourcegroups/ApoorvRG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dockerid'
       }
    ] 
    containers: [
       {
        name: instanceName 
        properties: {
          ports: [
             {
              port: 80
             }
          ] 
          image: image//'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
          resources: {
            requests: {
              cpu: cpu// 1
              memoryInGB: memory//'1.5'
            }
          }
        }
       }
    ] 
     
    osType: osType//'Linux'
    sku: sku//'Standard'
    ipAddress: {
      ports:  [
         {
          port: ipPort//80
          protocol: ipProtocol//'TCP'  
         }
      ]
      type: ipType //'Private' 
    }
    subnetIds: ipType=='Private' ?  [
       {
        id: subnetID
       }
    ] : null  
  }
}
