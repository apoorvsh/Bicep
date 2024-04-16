param (
    [Parameter(HelpMessage = "Id of the subscription to deploy the workload to.")]
    [string]
    $subscriptionId,
    
    [Parameter(HelpMessage = "Name of the workload to be deployed.")]
    [string[]]
    $workloadName,

    [Parameter(HelpMessage = "Location where resources need to be deployed.")]
    [string]
    $location,

    [Parameter(Mandatory = $false)]
    [bool]
    $whatif
)
    foreach ($name in $workloadName) {
        $deploymentName = "$name"
        $bicepFile = "workload\Sandbox\$name\$name.main.bicep"
        $parameterFile = "workload\Sandbox\$name\$name.bicepparam" 
        if ($whatif) {
            az deployment sub what-if  `
                --name $deploymentName `
                --template-file $bicepFile `
                --location $location `
                --parameters $parameterFile 
        }
        else {
            az deployment sub create  `
                --name $deploymentName `
                --template-file $bicepFile `
                --location $location `
                --parameters $parameterFile 
        }
    }


#$workloads = "resourceGroup", "network"
#.\Scripts\deployWorkload.ps1 -subscriptionId "367722a2-667e-40e3-ba4b-1078993dddf3" -workloadName $workloads  -location "eastus2" -whatif $false
