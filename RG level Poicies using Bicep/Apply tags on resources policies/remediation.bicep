param remediationName string 
param policyAssignmentId string
 param location string

resource remediations 'Microsoft.PolicyInsights/remediations@2021-10-01' = {
  name: remediationName
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
    policyAssignmentId: policyAssignmentId
    // The number of non-compliant resources to remediate. Can be between 1-50000. Default value is 500.
    resourceCount: 500
    resourceDiscoveryMode: 'ExistingNonCompliant' // Accepted these 2 Vaules 'ExistingNonCompliant' or 'ReEvaluateCompliance'
  }
}
