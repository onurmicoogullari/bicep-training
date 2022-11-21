@description('The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param pEnvironmentName string = 'dev'

@description('The unique name of the solution. This is used to ensure that resource names are unique.')
@minLength(5)
@maxLength(30)
param pSolutionName string = 'toyhr${uniqueString(resourceGroup().id)}'

@description('The number of App Service plan instances.')
@minValue(1)
@maxValue(10)
param pAppServicePlanInstanceCount int = 1

@description('The name nad tier of the App Service plan SKU.')
param pAppServicePlanSku object

@description('The Azure region into which the resources should be deployed.')
param pLocation string = 'westeurope'

@description('The administrator login username for the SQL server.')
@secure()
param pSqlServerAdministratorLogin string

@description('The administrator login password for the SQL server.')
@secure()
param pSqlServerAdministratorPassword string

@description('The name and tier of the SQL database SKU.')
param pSqlDatabaseSku object

var vAppServicePlanName = '${pEnvironmentName}-${pSolutionName}-plan'
var vAppServiceAppName = '${pEnvironmentName}-${pSolutionName}-app'
var vSqlServerName = '${pEnvironmentName}-${pSolutionName}-sql'
var vSqlDatabaseName = 'Employees'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: vAppServicePlanName
  location: pLocation
  sku: {
    name: pAppServicePlanSku.name
    tier: pAppServicePlanSku.tier
    capacity: pAppServicePlanInstanceCount
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: vAppServiceAppName
  location: pLocation
  properties: {
   serverFarmId: appServicePlan.id
   httpsOnly: true 
  }
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: vSqlServerName
  location: pLocation
  properties: {
    administratorLogin: pSqlServerAdministratorLogin
    administratorLoginPassword: pSqlServerAdministratorPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: vSqlDatabaseName
  location: pLocation
  sku: {
    name: pSqlDatabaseSku.name
    tier: pSqlDatabaseSku.tier
  }
}
