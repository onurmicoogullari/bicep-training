param pLocation string
param pAppServiceAppName string

@allowed([
  'nonprod'
  'prod'
])
param pEnvironmentType string

var vAppServicePlanName = 'toy-product-launch-plan'
var vAppServicePlanSkuName = (pEnvironmentType == 'prod') ? 'P2v3' : 'F1'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: vAppServicePlanName
  location: pLocation
  sku: {
    name: vAppServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: pAppServiceAppName
  location: pLocation
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true 
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
