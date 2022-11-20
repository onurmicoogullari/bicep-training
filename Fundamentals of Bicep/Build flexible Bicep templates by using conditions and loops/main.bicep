@description('The Azure regions into which the resources should be deployed.')
param pLocations array = [
  'westeurope'
  'eastus2'
  'eastasia'
]

@secure()
@description('The administrator login username for the SQL server.')
param pSqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param pSqlServerAdministratorLoginPassword string

@description('The IP address range for all virtual networks to use.')
param pVirtualNetworkAddressPrefix string = '10.10.0.0/16'

@description('The name and IP address range for each subnet in the virtual networks.')
param pSubnets array = [
  {
    name: 'frontend'
    ipAddressRange: '10.10.5.0/24'
  }
  {
    name: 'backend'
    ipAddressRange: '10.10.10.0/24'
  }
]

var vSubnetsProperties = [for vSubnet in pSubnets: {
  name: vSubnet.name
  properties: {
    addressPrefix: vSubnet.ipAddressRange
  }
}]

module databases 'modules/database.bicep' = [for vLocation in pLocations: {
  name: 'database-${vLocation}'
  params: {
    pLocation: vLocation
    pSqlServerAdministratorLogin: pSqlServerAdministratorLogin
    pSqlServerAdministratorLoginPassword: pSqlServerAdministratorLoginPassword
  }
}]

resource virtualNetworks 'Microsoft.Network/virtualNetworks@2022-05-01' = [for vLocation in pLocations: {
  name: 'teddybear-${vLocation}'
  location: vLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        pVirtualNetworkAddressPrefix
      ]
    }
    subnets: vSubnetsProperties
  }
}]


output serverInfo array = [for i in range(0, length(pLocations)): {
  name: databases[i].outputs.serverName
  location: databases[i].outputs.serverName
  fullyQualifiedDomainName: databases[i].outputs.serverFullyQualifiedDomainName
}]
