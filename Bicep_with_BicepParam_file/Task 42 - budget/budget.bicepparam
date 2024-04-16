using './budget.bicep'

param budgetname = 'hemangbudget'
param amount = 100
param category = 'Cost'
param timegrain = 'Monthly'
param startdate = '2023-10-01'
//param enddate = '2023-09-01'
//param RG = 'ResourceGroupName'
//param operator = 'In'
/*param filtervalue = [
  'UsageBased'
]*/
param actiongroupname = 'hemangactiongrp'
param location = 'global'
param enabled = true
param shortname = 'hemangagrp'

