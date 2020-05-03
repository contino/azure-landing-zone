# Scaffolding Pipeline Azure

## Building Infrastructure Platform
PoC/Lighthouse project at a potential new prospector. Simple application which can be taken at a client depending on the chosen cloud provider along with the application that can be enhanced further for demonstrable purposes of cloud adoption.

Part of the infrastructure platform the following Azure Resources are provisioned:
1) Key Vault
2) AKS Cluster
3) ACR (Container Registry)

##CI/CD Tool
The CI/CD tooling of choice is Azure DevOps. The pipeline is constructed as pipeline as code, you can find the CI/CD pipeline within `azure-pipeline.yaml`

##Design of Infrastructure
To interact with Azure APIs, AKS cluster requires service principal. A service principal is needed to dynamically create and managed other resources.

Part of the infrastructure build service principal is created for the AKS cluster. The application id and the secret is then stored in the keyvault created to store the credentials. Once the container registry is created the container registry is then  attached to the AKS cluster.

###Service Principal Creation
Part of this pipeline the service connection account was given permission to create service principal account.
Permission required to create service principal accounts using service principal are:
* The Service Principal requires Owner permission to the subscription 
* API access: Windows Azure Active Directory: "Manage apps that this app creates or owns" 
* Microsoft Graph "Read and write directory data", "Access directory as the signed in user"

The above permission can be found on the Supported legacy APIs `Azure Active Directory Graph`

More information on creating service principal with existing service principal
https://github.com/Azure/azure-powershell/issues/3215