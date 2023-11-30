targetScope = 'subscription'

param appName string
param location string
param adminGroupId string
param sqlRgName string
param sqlServerName string

resource rgShared 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${appName}-Shared-RG'
  location: location
}

module ownerRoleShared 'ts/wpc2023ts:role_assignment:1.0' = {
  scope: rgShared
  name: 'ownerRoleShared'
  params: {
    builtInRoleType: 'Owner' 
    principalId: adminGroupId
  }
}

module vnet 'ts/wpc2023ts:network:1.0' = {
  scope: rgShared
  name: 'vnet'
  params: {
    appName: appName
    location: location
    addressPrefix: ['10.0.0.0/16']
    subnet1Prefix: '10.0.0.0/24'
    subnet2Prefix: '10.0.1.0/24'
    sqlRgName: sqlRgName
    sqlServerName: sqlServerName
  }
}

output vnetIntegrationSubnetId string = vnet.outputs.vnetIntegrationSubnetId
