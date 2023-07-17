param asaInstanceName string
param appName string
param location string = resourceGroup().location
param tags object = {}
param relativePath string

resource asaInstance 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: asaInstanceName
  location: location
  tags: union(tags, { 'azd-service-name': appName })
  sku: {
      name: 'S0'
      tier: 'Standard'
    }
}

resource asaApp 'Microsoft.AppPlatform/Spring/apps@2022-12-01' = {
  name: appName
  location: location
  parent: asaInstance
  properties: {
    public: true
  }
}

resource asaDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-12-01' = {
  name: 'default'
  parent: asaApp
  properties: {
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
    source: {
      type: 'Jar'
      runtimeVersion: 'Java_17'
      relativePath: relativePath
    }
  }
}

output name string = asaApp.name
output uri string = 'https://${asaApp.properties.url}'
