using 'storage.bicep' 


param accessTier = 'Hot'
param containername = [
  'c1'
  'c2'
  'c3'
]

param count = 3
param kind = 'StorageV2'
param location = 'Central India'
param paccess = [
  'Blob'
  'Container'
  'None'
]

param storageAccountName = 'hemangshstorage'
param storageAccountSku = 'Standard_LRS'
