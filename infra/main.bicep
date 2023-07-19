targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Relative Path of ASA Jar')
param relativePath string

@allowed([
  'consumption'
  'standard'
])
param plan string = 'consumption'

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var asaManagedEnvironmentName = '${abbrs.appContainerAppsManagedEnvironment}${resourceToken}'
var asaInstanceName = '${abbrs.springApps}${resourceToken}'
var appName = 'demo'
var tags = {
  'azd-env-name': environmentName
  'spring-cloud-azure': 'true'
}


// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module springAppsConsumption 'modules/springapps/springappsConsumption.bicep' = if (plan == 'consumption') {
  name: '${deployment().name}--asaconsumption'
  scope: resourceGroup(rg.name)
  params: {
    location: location
	appName: appName
	tags: tags
	asaManagedEnvironmentName: asaManagedEnvironmentName
	asaInstanceName: asaInstanceName
	relativePath: relativePath
  }
}

module springAppsStandard 'modules/springapps/springappsStandard.bicep' = if (plan == 'standard') {
  name: '${deployment().name}--asastandard'
  scope: resourceGroup(rg.name)
  params: {
    location: location
	appName: appName
	tags: tags
	asaInstanceName: asaInstanceName
	relativePath: relativePath
  }
}

