param budgetname string
param amount int
param category string
param timegrain string
param startdate string
//param enddate string
//param RG string
//param operator string
//param filtervalue array
param actiongroupname string
param location string
param enabled bool
param shortname string




resource budget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: budgetname
  properties: { 
    amount: amount
    category: category
    timeGrain: timegrain
    timePeriod: {
      startDate: startdate
      //endDate: enddate  
    }
 
    
    filter: {
       
           dimensions: {
            name: 'Frequency'
            values:  [
              'UsageBased'
            ]
            operator: 'In'  
           }
            
    } 
  }  
}


resource actiongroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actiongroupname
  location: location
  properties: {
    enabled: enabled
    groupShortName: shortname
  } 
}
