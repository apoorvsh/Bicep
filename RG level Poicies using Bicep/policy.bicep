
param policyName string = 'Add or replace a tag on resource groups'
param policyDisplayName string = 'Add or replace a tag on resource groups'
param policyDescription string = 'This is an example of a built-in policy assigned to a resource group using Bicep.'
param location string = resourceGroup().location
param networkResourceGroupName string  = 'hub-rg'
param remediationName string = 'exampleRemediation'

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

resource remediations 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: remediationName
  dependsOn: [
    roleAssignment
  ]
  properties: {
    // Fail the remediation if the percentage of failed remediation operations exceeds a threshold. 0 means that the remediation will stop after the first failure. 100 means that the remediation will not stop even if all deployments fail. Default value is 100.
    failureThreshold: {
      percentage: 1
    }
    filters: {
      locations: [
        location
      ]
    }
    // The number of concurrent remediation deployments at any given time. Can be between 1-30. Default value is 10. Higher values will cause the remediation to complete more quickly, but increase the risk of throttling.
    parallelDeployments: 10
    policyAssignmentId: policyAssignment.id
    // The number of non-compliant resources to remediate. Can be between 1-50000. Default value is 500.
    resourceCount: 500
    resourceDiscoveryMode: 'ReEvaluateCompliance' // Accepted these 2 Vaules 'ExistingNonCompliant' or 'ReEvaluateCompliance'
  }
}





