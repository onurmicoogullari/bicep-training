@description('The Azure region into which the resources should be deployed.')
param pLocation string = 'westeurope'

@description('The name of the App Service app.')
param pAppServiceAppName string = 'toy-${uniqueString(resourceGroup().id)}'

@description('The name of the App Service plan SKU.')
param pAppServicePlanSkuName string = 'F1'

@description('Indicates whether a CDN should be deployed.')
param pDeployCdn bool = true

var vAppServicePlanName = 'toy-product-launch-plan'

module app 'modules/app.bicep' = {
  name: 'toy-launch-app'
  params: {
    pAppServiceAppName: pAppServiceAppName 
    pAppServicePlanName: vAppServicePlanName
    pAppServicePlanSkuName: pAppServicePlanSkuName
    pLocation: pLocation
  }
}

module cdn 'modules/cdn.bicep' = if (pDeployCdn) {
  name: 'toy-launch-cdn'
  params: {
    pHttpsOnly: true
    pOriginHostName: app.outputs.appServiceAppHostName
  }
}

@description('The host name to use to access the website.')
output websiteHostName string = pDeployCdn ? cdn.outputs.endpointHostName : app.outputs.appServiceAppHostName
