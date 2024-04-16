// Global parameters
@description('Define the project name or prefix for all objects.')
@minLength(1)
@maxLength(11)
param projectCode string
@description('Environment of Project')
param environment string
@description('Combine Resources Tags')
param combineResourceTags object
@description('Resource Location')
param location string

var userAssignedIdentityName = toLower('id-${projectCode}-${environment}-01')

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: userAssignedIdentityName
  tags: union({
      Name: userAssignedIdentityName
    }, combineResourceTags)
  location: location
}

output identityId string = identity.id
output principalId string = identity.properties.principalId
