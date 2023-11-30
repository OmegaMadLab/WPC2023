targetScope = 'subscription'

param appName string
param location string
param dbaGrpName string
param dbaGrpId string
param adminGrpId string

resource rgDb 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${appName}-DB-RG'
  location: location
}

module database 'ts/wpc2023ts:database:1.0' = {
  scope: rgDb
  name: 'database'
  params: {
    appName: appName
    location: location
    sqlServerEntraAdminName: dbaGrpName
    sqlServerEntraAdminId: dbaGrpId
  }
}

module contributorRoleDb 'ts/wpc2023ts:role_assignment:1.0' = {
  scope: rgDb
  name: 'contributorRoleDb'
  params: {
    builtInRoleType: 'Contributor' 
    principalId: dbaGrpId
  }
}

module ownerRoleDb 'ts/wpc2023ts:role_assignment:1.0' = {
  scope: rgDb
  name: 'ownerRoleDb'
  params: {
    builtInRoleType: 'Owner' 
    principalId: adminGrpId
  }
}

output sqlServerName string = database.outputs.sqlServerName
output sqlServerRgName string = database.outputs.sqlServerRgName
output sqlServerUri string = database.outputs.sqlServerUri
output sqlDbName string = database.outputs.sqlDbName
