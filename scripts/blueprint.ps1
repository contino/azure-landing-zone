param(
    [Parameter(Mandatory=$true)]
    [string]$BlueprintName,
    [Parameter(Mandatory=$true)]
    [String]$mgmtGroupName,
    [Parameter(Mandatory=$true)]
    [string]$version,
    [Parameter(Mandatory=$true)]
    [String]$KVAccessPolicy,
    [Parameter(Mandatory=$true)]
    [String]$SubId,
    [Parameter(Mandatory=$true)]
    [String]$UserIdentity
)

Install-Module Az.Blueprint -Force -AllowClobber
Import-Module Az.Blueprint

#Push Blueprint definition to Azure

#Import-AzBlueprintWithArtifact -Name "LandingZone" -ManagementGroupId "Management" -InputPath ./landingZone/blueprints -Force
#$bp = Get-AzBlueprint -Name "LandingZone" -ManagementGroupId "Management"
#Publish-AzBlueprint -Blueprint $bp -Version 1.0

# Get the version of the blueprint you want to assign, which we will pas to New-AzBlueprintAssignment
#$publishedBp = Get-AzBlueprint -ManagementGroupId "Management" -Name "LandingZone" -LatestPublished

#$parameters = @{
#    "KV-AccessPolicy"="ef044b03-2a5d-4251-96ee-e6065b0d3b3b";
#    "SubscriptionId"="42fd229c-db07-42d3-be34-bc5c98826bc2"
#}


#$UserAssignedPrincipalId = "/subscriptions/42fd229c-db07-42d3-be34-bc5c98826bc2/resourceGroups/cloud-shell-storage-westeurope/providers/Microsoft.ManagedIdentity/userAssignedIdentities/blueprint"

#New-AzBlueprintAssignment -Name "LandingZoneAssignment" -Blueprint $publishedBp -Location "UK South" -SubscriptionId "42fd229c-db07-42d3-be34-bc5c98826bc2" -Parameter $parameters -UserAssignedIdentity $UserAssignedPrincipalId

function Set-LZBluePrint {
    param(
    [Parameter(Mandatory=$true)]
    [string]$BlueprintName,
    [Parameter(Mandatory=$true)]
    [String]$mgmtGroupName,
    [Parameter(Mandatory=$true)]
    [string]$version,
    [Parameter(Mandatory=$true)]
    [String]$KVAccessPolicy,
    [Parameter(Mandatory=$true)]
    [String]$SubId,
    [Parameter(Mandatory=$true)]
    [String]$UserIdentity
    )

    $bp_exists = Get-AzBlueprint -Name $BlueprintName -ManagementGroupId $mgmtGroupName -Version $version -ErrorAction SilentlyContinue
    if($null -eq $bp_exists){
        Import-AzBlueprintWithArtifact -Name $BlueprintName -ManagementGroupId $mgmtGroupName -InputPath ./landingZone/blueprints -Force
        $bp = Get-AzBlueprint -Name $BlueprintName -ManagementGroupId $mgmtGroupName

        Write-Host "Publishing Blueprint"
        Publish-AzBlueprint -Blueprint $bp -Version $version

        # Get the version of the blueprint you want to assign, which we will pas to New-AzBlueprintAssignment
        $publishedBp = Get-AzBlueprint -ManagementGroupId "Management" -Name "LandingZone" -LatestPublished

        $parameters = @{
            "KV-AccessPolicy"=$KVAccessPolicy;
            "SubscriptionId"=$SubId
        }

        New-AzBlueprintAssignment -Name "$($BlueprintName)-$($version)" -Blueprint $publishedBp -Location "UK South" -SubscriptionId $SubId -Parameter $parameters -UserAssignedIdentity $UserIdentity
    }
    else
    {
        Write-Host "Blueprint Version exists"
        Set-AzBlueprintAssignment -Name "$($BlueprintName)-$($version)" -Blueprint $bp_exists -ManagementGroupId $mgmtGroupName -Parameter $parameters -UserAssignedIdentity $UserIdentity
    }
}

Set-LZBluePrint -BlueprintName $BlueprintName -mgmtGroupName $mgmtGroupName $version -KVAccessPolicy $KVAccessPolicy -SubId $SubId -UserIdentity $UserIdentity