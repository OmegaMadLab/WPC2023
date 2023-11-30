param appName string
param location string
param sqlServerEntraAdminName string
param sqlServerEntraAdminId string

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: '${appName}-SQLSRV'
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: sqlServerEntraAdminName
      sid: sqlServerEntraAdminId
    }
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}

resource db 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: '${appName}-DB'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    maxSizeBytes: 2147483648
  }
}

output sqlServerName string = sqlServer.name
output sqlServerRgName string = resourceGroup().name
output sqlServerUri string = sqlServer.properties.fullyQualifiedDomainName
output sqlDbName string = db.name

