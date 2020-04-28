az login --service-principal -u $env:AZURE_CLIENT_ID -p $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID
az group create --name vpaks -l uksouth
az group deployment create -g vpaks --template-file .\azuredeploy.json --parameters .\azuredeploy.parameters.json