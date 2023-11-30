targetScope = 'subscription'

param appName string
param location string

param adminGrpName string
param devGrpName string
param dbaGrpName string

// Deployment Script to get EntraID info
module getEntraIdInfo 'ts/wpc2023ts:getEntraIdInfo:1.0' = {
  scope: resourceGroup('WPC2023-ManagedIdentity-RG')
  name: 'deploymentScript'
  params: {
    AdminGroupName: adminGrpName
    DbaGroupName: dbaGrpName
    DevGroupName: devGrpName
    location: location
  }
}

// Database resources
module data 'ts/wpc2023ts:data_layer:1.0' = {
  name: 'data'
  params: {
    appName: appName
    location: location
    adminGrpId: getEntraIdInfo.outputs.AdminGroupId
    dbaGrpId: getEntraIdInfo.outputs.DbaGroupId
    dbaGrpName: dbaGrpName 
  }
}

// Shared resources
module shared 'ts/wpc2023ts:shared_layer:1.0' = {
  name: 'shared'
  params: {
    appName: appName
    location: location
    adminGroupId: getEntraIdInfo.outputs.AdminGroupId
    sqlRgName: data.outputs.sqlServerRgName
    sqlServerName: data.outputs.sqlServerName
  }
}

// Frontend resources
// module frontend 'ts/wpc2023ts:frontend_layer:1.0' = {
//   name: 'frontend'
//   params: {
//     appName: appName
//     location: location
//     adminGroupId: getEntraIdInfo.outputs.AdminGroupId
//     devGroupId: getEntraIdInfo.outputs.DevGroupId
//     sqlDbName: data.outputs.sqlDbName
//     sqlServerUri: data.outputs.sqlServerUri
//     subnetId: shared.outputs.vnetIntegrationSubnetId
//   }
// }


