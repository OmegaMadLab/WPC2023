targetScope = 'subscription'

param appName string
param location string
param subnetId string
param sqlDbName string
param sqlServerUri string
param devGroupId string
param adminGroupId string

resource rgFe 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${appName}-FE-RG'
  location: location
}

module webApp 'ts/wpc2023ts:webApp:1.0' = {
  scope: rgFe
  name: 'webApp'
  params: {
    appName: appName
    location: location
    subnetId: subnetId
    sqlDbName: sqlDbName
    sqlServerUri: sqlServerUri
  }
}

module contributorRoleFe 'ts/wpc2023ts:role_assignment:1.0' = {
  scope: rgFe
  name: 'contributorRoleFe'
  params: {
    builtInRoleType: 'Contributor' 
    principalId: devGroupId
  }
}

module ownerRoleFe 'ts/wpc2023ts:role_assignment:1.0' = {
  scope: rgFe
  name: 'ownerRoleFe'
  params: {
    builtInRoleType: 'Owner' 
    principalId: adminGroupId
  }
}

output webAppUrl string = webApp.outputs.webAppUrl
