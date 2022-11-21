@description('The host name (address) of the origin server.')
param pOriginHostName string

@description('The name of the CDN profile.')
param pProfileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('The name of the CDN endpoint')
param pEndpointName string = 'endpoint-${uniqueString(resourceGroup().id)}'

@description('Indicates whether the CDN endpoint requires HTTPS connections.')
param pHttpsOnly bool

var vOriginName = 'my-origin'

resource cdnProfile 'Microsoft.Cdn/profiles@2022-05-01-preview' = {
  name: pProfileName
  location: 'global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2022-05-01-preview' = {
  parent: cdnProfile
  name: pEndpointName
  location: 'global'
  properties: {
    originHostHeader: pOriginHostName
    isHttpAllowed: !pHttpsOnly
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: vOriginName
        properties: {
          hostName: pOriginHostName
        }
      }
    ]
  }
}

@description('The host name of the CDN endpoint.')
output endpointHostName string = endpoint.properties.hostName
