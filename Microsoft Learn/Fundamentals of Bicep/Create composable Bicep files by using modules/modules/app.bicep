@description('The Azure region into which the resources should be deployed.')
param pLocation string

@description('The name of the App Service app.')
param pAppServiceAppName string

@description('The name of the App Service plan.')
param pAppServicePlanName string

@description('The name of the App Service plan SKU.')
param pAppServicePlanSkuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: pAppServicePlanName
  location: pLocation
  sku: {
    name: pAppServicePlanSkuName
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

@description('The default host name of the App Service app.')
output appServiceAppHostName string = appServiceApp.properties.defaultHostName
