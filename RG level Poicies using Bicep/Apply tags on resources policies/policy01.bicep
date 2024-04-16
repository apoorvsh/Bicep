
param policyName string = 'Add or replace a tag on resource groups'
param policyDisplayName string = 'Add or replace a tag on resource groups'
param policyDescription string = 'This is an example of a built-in policy assigned to a resource group using Bicep.'
param location string = resourceGroup().location
param networkResourceGroupName string  = 'sample-rg'
param remediationName string = 'exampleRemediation'
param remediation bool = true


var roleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var policyDefinitionId = '/providers/Microsoft.Authorization/policyDefinitions/d157c373-a6c4-483d-aaad-570756956268'

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' =  {
  name: policyName
  location : location
  identity: {
    type: 'SystemAssigned'
  }
  //scope: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroupName}' // Replace with your subscription ID and resource group name
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    parameters: {
      tagName: {
        value: 'Environment'
      }
      tagValue: {
        value: 'Prod'
      }
    }
    //scope: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${networkResourceGroupName}' // Replace with your subscription ID and resource group name
    policyDefinitionId: policyDefinitionId // Replace with the appropriate policy definition ID
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  //name: guid(policyAssignment.id, resourceGroup().id, roleDefinitionId)
  name: guid(uniqueString(networkResourceGroupName))
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionId}'
    principalId: policyAssignment.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

module remediationsTask 'remediation.bicep' = if (remediation) {
  dependsOn: [
    roleAssignment// policyAssignment
  ]
  name:'remediation'
  params: {
 remediationName: remediationName
 policyAssignmentId: policyAssignment.id
 location: location

  }
}





