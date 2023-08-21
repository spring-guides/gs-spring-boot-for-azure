#!/bin/bash

#      Copyright (c) Microsoft Corporation.
#      Copyright (c) IBM Corporation. 
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#           http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

set -Eeuo pipefail

# Fail fast the deployment if envs are empty
if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "The subscription Id is not successfully retrieved, please retry another deployment." >&2
  exit 1
fi

if [[ -z "$RESOURCE_GROUP" ]]; then
  echo "The resource group is not successfully retrieved, please retry another deployment." >&2
  exit 1
fi

if [[ -z "$ASA_SERVICE_NAME" ]]; then
  echo "The Azure Spring Apps service name is not successfully retrieved, please retry another deployment." >&2
  exit 1
fi

jar_file_name="hello-world-0.0.1.jar"
source_url="https://github.com/Azure/spring-cloud-azure-tools/releases/download/0.0.1/$jar_file_name"
auth_header="no-auth"

# Download binary
echo "Downloading binary from $source_url to $jar_file_name"
if [ "$auth_header" == "no-auth" ]; then
    curl -L "$source_url" -o $jar_file_name
else
    curl -H "Authorization: $auth_header" "$source_url" -o $jar_file_name
fi

az extension add --name spring --upgrade
az spring app deploy --resource-group $RESOURCE_GROUP --service $ASA_SERVICE_NAME --name demo --artifact-path $jar_file_name

# Delete uami generated before exiting the script
az identity delete --ids ${AZ_SCRIPTS_USER_ASSIGNED_IDENTITY}