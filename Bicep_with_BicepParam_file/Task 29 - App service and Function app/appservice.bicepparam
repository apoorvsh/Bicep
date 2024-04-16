using './appservice.bicep'

param name = 'hemangappservice'
param location = 'centralindia'
param hostingPlanName = 'ASP-HemangRG-b523'
param alwaysOn = false
param ftpsState = 'FtpsOnly'
param sku = 'PremiumV3'
param skuCode = 'P1V3'
param linuxFxVersion = 'PYTHON|3.11'

