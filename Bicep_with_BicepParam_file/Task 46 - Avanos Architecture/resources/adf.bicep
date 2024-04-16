param values object 



resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: values.adfName
  location: values.location
  identity: {
    type: values.type
  }
  properties: {
    publicNetworkAccess: values.networkAccess
  }
}


output adfId string = dataFactory.id
