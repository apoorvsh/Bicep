using './spark.bicep'

param workspaceName = 'hemangnewworkspace'
param sqlAdministratorLogin = 'username'
param sqlAdministratorLoginPassword = 'Hemang@1`2345'
param location = 'Central India'
param saName = 'storageforsparktaskct'
param sparkname = 'hemangspark'
param sqlpoolname = 'myfirstsqlpool'
param firewallRuleName = [
  'hemangfirstfirewall'
  'hemangsecondfirewall'
]
param firewallRulesEnd = [
  '192.168.1.10' 
  '10.0.0.10'
]

param firewallRulesStart = [
  '192.168.1.1' 
  '10.0.0.1'
]


