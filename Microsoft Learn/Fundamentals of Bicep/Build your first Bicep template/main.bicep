param pLocation string = 'westeurope'
param pStorageAccountName string = 'toylaunch${uniqueString(resourceGroup().id)}'
param pAppServiceAppName string = 'toylaunch${uniqueString(resourceGroup().id)}'

@allowed([
  'nonprod'
  'prod'
])
param pEnvironmentType string

var vStorageAccountSkuName = (pEnvironmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'


resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: pStorageAccountName
  location: pLocation
  sku: {
    name: vStorageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    pAppServiceAppName: pAppServiceAppName 
    pEnvironmentType: pEnvironmentType
    pLocation: pLocation
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
