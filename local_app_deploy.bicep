targetScope = 'subscription'

param appName string
param location string

param adminGrpName string
param devGrpName string
param dbaGrpName string

// Deployment Script to get EntraID info
module getEntraIdInfo 'local_modules/deploymentScript.bicep' = {
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
module data 'local_modules/data_layer.bicep' = {
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
module shared 'local_modules/shared_layer.bicep' = {
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
module frontend 'local_modules/frontend_layer.bicep' = {
  name: 'frontend'
  params: {
    appName: appName
    location: location
    adminGroupId: getEntraIdInfo.outputs.AdminGroupId
    devGroupId: getEntraIdInfo.outputs.DevGroupId
    sqlDbName: data.outputs.sqlDbName
    sqlServerUri: data.outputs.sqlServerUri
    subnetId: shared.outputs.vnetIntegrationSubnetId
  }
}


