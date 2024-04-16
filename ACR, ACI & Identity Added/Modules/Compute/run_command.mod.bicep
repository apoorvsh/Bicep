@description('Resource Location')
param location string
@description('Existing Virtual Machine')
param existingVmName string

resource existingVirtualMachine 'Microsoft.Compute/virtualMachines@2023-07-01' existing = {
  name: existingVmName
}

resource vmFEIISEnabled 'Microsoft.Compute/virtualMachines/runCommands@2023-07-01' = {
  name: 'vm-EnableIIS-Script'
  location: location
  parent: existingVirtualMachine
  properties: {
    asyncExecution: false
    source: {
      script: '''
        Install-WindowsFeature -name Web-Server -IncludeManagementTools
        Remove-Item C:\\inetpub\\wwwroot\\iisstart.htm
        Add-Content -Path "C:\\inetpub\\wwwroot\\iisstart.htm" -Value $("Hello from " + $env:computername)  
      '''
    }
  }
}
