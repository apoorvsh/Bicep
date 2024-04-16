param autoname string
param location string



resource symbolicname 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: autoname
  location: location
  identity: {
     type: 'SystemAssigned'
  } 
  properties: {
     sku: {
      name:  'Basic'
     }
  }  
}
