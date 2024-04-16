using './sql.bicep'

param SqlServerName = 'hemangservernewtask'
param SqlDatabase = 'hdatabse'
param adminLogin = 'hemangdata'
param adminPassword =  getSecret('e998d3e7-b93b-4cf2-8087-c1fbe787c337', 'Hemang_RG', 'newkeyvaultsqldatabase', 'key')
param location = 'centralindia'

