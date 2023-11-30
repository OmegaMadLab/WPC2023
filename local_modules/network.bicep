
param appName string
param location string
param addressPrefix string[]
param subnet1Prefix string
param subnet2Prefix string
param sqlRgName string
param sqlServerName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: '${appName}-VNET'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefix
    }
    subnets: [
      {
        name: 'subnet1'
        properties: {
          delegations: [
            {
              name: 'webAppDelegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          addressPrefix: subnet1Prefix
        }
      }
      {
        name: 'subnet2'
        properties: {
          addressPrefix: subnet2Prefix
        }
      }
    ]
  }
}

resource sqlPrivateLinkDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.sqlServerHostname}'
  location: 'global'
}

resource dnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: sqlPrivateLinkDnsZone
  name: vnet.name
  location: 'global' 
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource existingSql 'Microsoft.Sql/servers@2021-11-01' existing = {
  name: sqlServerName
  scope: resourceGroup(sqlRgName)
}

var peName = '${appName}-SQL-PE'

resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: peName
  location: location
  properties: {
    subnet: {
      id: vnet.properties.subnets[1].id
    }
    privateLinkServiceConnections: [
      {
        name: peName
        properties: {
          privateLinkServiceId: existingSql.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource peDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  parent: sqlPrivateEndpoint
  name: 'privateEndpoint-ZoneGroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: sqlPrivateLinkDnsZone.id
        }
      }
    ]
  }
}

output vnetIntegrationSubnetId string = vnet.properties.subnets[0].id
