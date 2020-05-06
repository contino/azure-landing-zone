Install-Module Az.Blueprint -Force -AllowClobber
Import-Module Az.Blueprint

#Push Blueprint definition to Azure

Import-AzBlueprintWithArtifact -Name "LandingZone" -ManagementGroupId "Management" -InputPath ./landingZone/blueprints -Force
$bp = Get-AzBlueprint -Name "LandingZone" -ManagementGroupId "Management"
Publish-AzBlueprint -Blueprint $bp -Version 1.0

# Get the version of the blueprint you want to assign, which we will pas to New-AzBlueprintAssignment
$publishedBp = Get-AzBlueprint -ManagementGroupId "Management" -Name "LandingZone" -LatestPublished

$parameters = @{
    "KV-AccessPolicy"="ef044b03-2a5d-4251-96ee-e6065b0d3b3b";
    "SubscriptionId"="42fd229c-db07-42d3-be34-bc5c98826bc2"
}

New-AzBlueprintAssignment -Name "LandingZoneAssignment" -Blueprint $publishedBp -Location "UK South" -SubscriptionId "42fd229c-db07-42d3-be34-bc5c98826bc2" -Parameter $parameters