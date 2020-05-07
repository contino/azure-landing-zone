az login --service-principal -u $env:AZURE_CLIENT_ID -p $env:AZURE_CLIENT_SECRET --tenant $env:AZURE_TENANT_ID
az group create --name demo-acr -l uksouth
az group deployment create -g demo-acr --template-file ./acrdeploy.json --parameters ./acrdeploy.parameters.json