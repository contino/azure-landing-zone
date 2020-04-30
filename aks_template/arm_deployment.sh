az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID
az group create --name aks-demo -l uksouth
az group deployment create -g aks-demo --template-file ./aksdeploy.json --parameters ./aksdeploy.parameters.json