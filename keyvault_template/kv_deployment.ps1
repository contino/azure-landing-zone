az login --service-principal -u $env:AZURE_CLIENT_ID -p $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID
az group create --name kv-infra-demo -l uksouth
az group deployment create -g kv-infra-demo --template-file .\keyvault_deploy.json --parameters .\keyvault_deploy.parameters.json