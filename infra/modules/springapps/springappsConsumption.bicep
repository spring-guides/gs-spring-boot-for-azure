param location string = resourceGroup().location
param asaManagedEnvironmentName string
param asaInstanceName string
param appName string
param tags object = {}
param relativePath string

resource asaManagedEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' = {
  name: asaManagedEnvironmentName
  location: location
  tags: tags
  properties: {
	workloadProfiles: [
	  {
	    name: 'Consumption'
		workloadProfileType: 'Consumption'
	  }
    ]
  }
}

resource asaInstance 'Microsoft.AppPlatform/Spring@2023-03-01-preview' = {
  name: asaInstanceName
  location: location
  tags: union(tags, { 'azd-service-name': appName })
  sku: {
    name: 'S0'
	tier: 'StandardGen2'
  }
  properties: {
	managedEnvironmentId: asaManagedEnvironment.id
  }
}

resource asaApp 'Microsoft.AppPlatform/Spring/apps@2023-03-01-preview' = {
  name: appName
  location: location
  parent: asaInstance
  properties: {
    public: true
  }
}

resource asaDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2023-03-01-preview' = {
  name: 'default'
  parent: asaApp
  properties: {
    source: {
      type: 'Jar'
      relativePath: relativePath
      runtimeVersion: 'Java_17'
    }
    deploymentSettings: {
      resourceRequests: {
        cpu: '1'
        memory: '2Gi'
      }
    }
  }
}

output name string = asaApp.name
output uri string = 'https://${asaApp.properties.url}'