
param appName string
param subnetId string
param location string
param sqlServerUri string
param sqlDbName string

var appServicePlanName = '${appName}-ASP'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${appName}-WEBAPP'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
      connectionStrings: [
        {
          name: 'db'
          connectionString: 'Server=${sqlServerUri};Database=${sqlDbName};Authentication=Active Directory Default;'
          type: 'SQLAzure'
        }
      ]
    }
  }
}

resource vnetConfig 'Microsoft.Web/sites/networkConfig@2022-09-01' = {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetId
  }
}

output webAppUrl string = webApp.properties.defaultHostName
