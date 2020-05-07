# Scaffolding Pipeline Azure

## Building Infrastructure Platform
PoC/Lighthouse project at a potential new prospector. This is to create Landing Zone within Azure. The Landing Zone will consist of:
* Key Vault
* vNet
* NSG
* Log Analytics
* Storage Account

![Azure Landing Zone](https://docs.microsoft.com/en-us/azure/governance/blueprints/media/caf-blueprints/caf-migration-landing-zone-architecture.png)

More information on Azure Landing zone can be found <a href=https://docs.microsoft.com/en-us/azure/governance/blueprints/samples/caf-migrate-landing-zone> here</a>

Building the Landing Zone was using Azure Blueprints. You can find great examples of Azure Blueprints <a href=https://github.com/Azure/azure-blueprints> here</a>

## CI/CD Tool
The CI/CD tooling of choice is Azure DevOps. The pipeline is constructed as pipeline as code, you can find the CI/CD pipeline within `azure-pipeline.yaml`

## Getting Started
To run the pipeline within your sandbox Azure DevOps & Azure Tenant create new project within Azure DevOps. Link the github repository to the project. Once done create new service connection to your Azure tenant.

In order to create Management Groups with the service connection, add the service connection SPN within the Access Control at the default Tenant Root Group level. Add the SPN as Owner.

## Blueprints

#### Prerequisites
If you've never used Blueprints before, this can be little overwhelming. You can build your first blueprint with the UI to understand how everything works. You can try it at aka.ms/getblueprints and learn more about it in the docs or watch this <a href="https://www.youtube.com/watch?v=cQ9D-d6KkMY"> 15 minute overview.</a>

**Download the <a href="https://powershellgallery.com/packages/Az.Blueprint/">Az.Blueprint module</a> from the powershell gallary:**

`Install-Module -Name Az.Blueprint`

#### Quickstart
To push blueprint definition to Azure

`Import-AzBlueprintWithArtifact -Name LandingZone -ManagementGroupId "DevMG" -InputPath  ".\landingZone\blueprint"`

Publish a new version of that definition so it can be assigned:
```powershell
# Get the blueprint we just created
$bp = Get-AzBlueprint -Name Boilerplate -ManagementGroupId "DevMG"
# Publish version 1.0
Publish-AzBlueprint -Blueprint $bp -Version 1.0
```

Assign the blueprint to a subscription

```powershell
# Get the version of the blueprint you want to assign, which we will pas to New-AzBlueprintAssignment
$publishedBp = Get-AzBlueprint -ManagementGroupId "DevMG" -Name "LandingZone" -LatestPublished

# Each resource group artifact in the blueprint will need a hashtable for the actual RG name and location
$rgHash = @{ name="MyBoilerplateRG"; location = "eastus" }

# all other (non-rg) parameters are listed in a single hashtable, with a key/value pair for each parameter
$parameters = @{ principalIds="caeebed6-cfa8-45ff-9d8a-03dba4ef9a7d" }

# All of the resource group artifact hashtables are themselves grouped into a parent hashtable
# the 'key' for each item in the table should match the RG placeholder name in the blueprint
$rgArray = @{ SingleRG = $rgHash }

# Assign the new blueprint to the specified subscription (Assignment updates should use Set-AzBlueprintAssignment
New-AzBlueprintAssignment -Name "UniqueBlueprintAssignmentName" -Blueprint $publishedBp -Location eastus -SubscriptionId "00000000-1111-0000-1111-000000000000" -ResourceGroupParameter $rgArray -Parameter $parameters
```

#### Structure of blueprint artifacts
A blueprint consists of the main blueprint json file and a series of artifact json files.
The blueprint folder structure will be like the following:

```json
Blueprint directory
* blueprint.json
* artifacts
 - artifact.json
 - ...
 - more-artifacts.json
```

##### Blueprint Folder
The blueprint folder can be found `landingZone\blueprints`. Running the pipeline will execute `.\scripts\blueprint.ps1`

The script is taking two parameters which are stored as hash table. The `KV-AccessPolicy` is the object ID of the Azure DevOps service connection (SPN) that assigns itself access once the Key Vault is created. The `SubscriptionId` is part of the resourceId when adding diagnostic settings to each of the resources. 

## Management Groups
As part of the repository having there is example of implementing Management Groups within Azure. The powershell script is located within `.\scripts\mgmtGroup.ps1` The script will look for json file located within `.\mgmtGroup\management.json` 

```json
{
  "MgmtGroup": {
    "GroupName": [
      {
        "name": "RootLevel"
      },
      {
        "name": "Management",
        "parent": "RootLevel",
        "subscriptionId": "xxxxx-xxxx-xxx-xxx-xxxxx"
      }
    ]
  }
}
```

Each child consits details of the management group to be created the above examples shows management groups called:

* RootLevel
* Management

The RootLevel is implemented underneath tenant level subsequent groups are then managed under the root level. The management group is child of the RootLevel management group. Below image illustrates design of the Management Group level 

![Azure Management Group](https://docs.microsoft.com/en-us/azure/governance/management-groups/media/tree.png)

The above image RootLevel is "Root Management Group"



## Extra Resources
Part of the repository you will find ARM Template building out resources such as:

1) Key Vault
2) AKS Cluster
3) ACR (Container Registry)

#### AKS
To interact with Azure APIs, AKS cluster requires service principal. A service principal is needed to dynamically create and managed other resources.

Part of the infrastructure build service principal is created for the AKS cluster. The application id and the secret is then stored in the keyvault created to store the credentials. Once the container registry is created the container registry is then  attached to the AKS cluster.

#### Service Principal Creation
Idea would be to have the pipeline to create SPN accounts in order to assign to resources such as AKS cluster. To create SPN account as a SPN you need to add permissions to your service connection account. Permission required to create service principal accounts using service principal are:
* The Service Principal requires Owner permission to the subscription 
* API access: Windows Azure Active Directory: "Manage apps that this app creates or owns" 
* Microsoft Graph "Read and write directory data", "Access directory as the signed in user"

The above permission can be found on the Supported legacy APIs `Azure Active Directory Graph`

More information on creating service principal with existing service principal can be found
<a href=https://github.com/Azure/azure-powershell/issues/3215>here</a>.

Example of the working pipeline can be found on `extra-azure-pipeline.yaml`
