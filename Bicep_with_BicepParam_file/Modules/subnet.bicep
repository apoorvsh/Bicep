param subnetname string
param subnetprefix string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnetname
  properties: {
     addressPrefix: subnetprefix
  }
}
