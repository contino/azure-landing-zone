az login --service-principal -u $env:AZURE_CLIENT_ID -p $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID
az group create --name infra-demo -l uksouth
az group deployment create -g infra-demo --template-file .\azuredeploy.json --parameters .\azuredeploy.parameters.json