param location string
param privateEndpointName array 
param vnetName string 
param vnetAddressPrefix string 
param subnetName string 
param subnetAddressPrefix string  
param privateDNSZoneName array
param groupids array
param linkservicename array
param workspaceName string
param sqlAdministratorLogin string
@secure()
param sqlAdministratorLoginPassword string
param saName string
param loganalyticsworkspaceName string



resource vnet 'Microsoft.Network/virtualnetworks@2022-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes:  [
        vnetAddressPrefix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualnetworks/subnets@2022-09-01' = {
  name: subnetName
  parent: vnet
  properties: {
    addressPrefix: subnetAddressPrefix
  }
  
}




resource synapseWorkspace 'Microsoft.Synapse/workspaces@2019-06-01-preview' = {
  name: workspaceName
  location: location
   identity: {
     type: 'SystemAssigned'
   }
  properties: {
    defaultDataLakeStorage: {
        accountUrl: format('https://{0}.dfs.core.windows.net', saName)
         filesystem: 'hemanglakefile'
    }
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    
    
  }
 
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' ={
  name: loganalyticsworkspaceName
  location: location
  properties:{
    retentionInDays: 30
    sku: {
      name: 'pergb2018'
    }
  }
}

resource diagno 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'firstdiagno'
  scope: synapseWorkspace
 properties: {
   workspaceId: logAnalytics.id //'/subscriptions/e998d3e7-b93b-4cf2-8087-c1fbe787c337/resourceGroups/Hemang_RG/providers/Microsoft.OperationalInsights/workspaces/hemangworklogs'	
   

 }
}

resource integrationruntime 'Microsoft.Synapse/workspaces/integrationRuntimes@2021-06-01' = {
  name: 'string'
  parent: synapseWorkspace
  properties: {
    type: 'SelfHosted'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = [ for i in range (0,3):  {
  name: privateEndpointName[i]
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: linkservicename[i]
        properties: {
          privateLinkServiceId: synapseWorkspace.id
          groupIds: [
            groupids[i]
          ]
        }
      }
      
    ]
    customNetworkInterfaceName: 'HemangNic${i+1}'
  }
 
}]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = [ for i in range (0,3):{
  name: privateDNSZoneName[i]
  location: 'global'

}]

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' =[ for i in range (0,3): {
  name: 'link${i+1}'
  parent: privateDnsZone[i]
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id 
    }
  }
 
}]

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = [ for i in range (0,3): {
  name: 'mydnsgroupname${i+1}'
  parent: privateEndpoint[i]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone[i].id
        }
      }
    ]
  }
  
}]

//output outputName string = VNET.id
