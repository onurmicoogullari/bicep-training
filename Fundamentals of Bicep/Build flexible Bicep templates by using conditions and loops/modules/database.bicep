@description('The Azure region into which the resources should be deployed.')
param pLocation string

@secure()
@description('The administrator login username for the SQL server.')
param pSqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param pSqlServerAdministratorLoginPassword string

@description('The name and tier of the SQL database SKU.')
param pSqlDatabaseSku object = {
  name: 'Standard'
  tier: 'Standard'
}

@description('The name of the environment. This must be Development or Production.')
@allowed([
  'Development'
  'Production'
])
param pEnvironmentName string = 'Development'

@description('The name of the audit storage account SKU.')
param pAuditStorageAccountSkuName string = 'Standard_LRS'

var vSqlServerName = 'teddy${pLocation}${uniqueString(resourceGroup().id)}'
var vSqlDatabaseName = 'TeddyBear'
var vAuditingEnabled = pEnvironmentName == 'Production'
var vAuditStorageAccountName = take('bearaudit${pLocation}${uniqueString(resourceGroup().id)}', 24)

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: vSqlServerName
  location: pLocation
  properties: {
    administratorLogin: pSqlServerAdministratorLogin
    administratorLoginPassword: pSqlServerAdministratorLoginPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: vSqlDatabaseName
  location: pLocation
  sku: pSqlDatabaseSku
}

resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = if (vAuditingEnabled) {
  name: vAuditStorageAccountName
  location: pLocation
  sku: {
    name: pAuditStorageAccountSkuName
  }
  kind: 'StorageV2'
}

resource sqlServerAduit 'Microsoft.Sql/servers/auditingSettings@2022-05-01-preview' = if (vAuditingEnabled) {
  parent: sqlServer
  name: 'default'
  properties: {
    state: 'Enabled'
    storageEndpoint: vAuditingEnabled ? auditStorageAccount.properties.primaryEndpoints.blob : ''
    storageAccountAccessKey: vAuditingEnabled ? listKeys(auditStorageAccount.id, auditStorageAccount.apiVersion).keys[0].value : ''
  }
}

output serverName string = sqlServer.name
output location string = pLocation
output serverFullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
