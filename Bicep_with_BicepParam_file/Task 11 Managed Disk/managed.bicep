param count int = 2




resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' existing = {
  name: 'bicepvm'
  
}

resource diskResources 'Microsoft.Compute/disks@2022-07-02' = [for i in range(0,count): {
  name: 'mdisk${i+1}'
  location: 'East US'
  properties: {
     creationData: {
      createOption: 'Empty'
     }
      diskSizeGB: 1023
  }
  dependsOn: [
    vm
  ]
}]
