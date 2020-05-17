param(
    [Parameter(Mandatory=$true)]
    [string]$BlueprintName,
    [Parameter(Mandatory=$true)]
    [String]$mgmtGroupName,
    [Parameter(Mandatory=$true)]
    [String]$KVAccessPolicy,
    [Parameter(Mandatory=$true)]
    [String]$SubId,
    [Parameter(Mandatory=$true)]
    [String]$UserIdentity
)

Install-Module Az.Blueprint -Force -AllowClobber
Import-Module Az.Blueprint

function Set-LZBluePrint {
    param(
    [Parameter(Mandatory=$true)]
    [string]$BlueprintName,
    [Parameter(Mandatory=$true)]
    [String]$mgmtGroupName,
    [Parameter(Mandatory=$true)]
    [String]$KVAccessPolicy,
    [Parameter(Mandatory=$true)]
    [String]$SubId,
    [Parameter(Mandatory=$true)]
    [String]$UserIdentity
    )

    $version = Get-Date -format "yyyyMMddssmm"

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
        Write-Host "Assignment Name + $($BlueprintName)$($version)"
        New-AzBlueprintAssignment -Name "$($BlueprintName)$($version)" -Blueprint $publishedBp -Location "UK South" -SubscriptionId $env:SUBID -Parameter $parameters -UserAssignedIdentity $UserIdentity
    }
    else
    {
        Write-Host "Blueprint Version exists"
        Write-Host "Assignment Name + $($BlueprintName)$($version)"
        Set-AzBlueprintAssignment -Name "$($BlueprintName)$($version)" -Blueprint $bp_exists -ManagementGroupId $mgmtGroupName -Parameter $parameters -UserAssignedIdentity $UserIdentity
    }
}

Set-LZBluePrint -BlueprintName $BlueprintName -mgmtGroupName $mgmtGroupName -KVAccessPolicy $KVAccessPolicy -SubId $SubId -UserIdentity $UserIdentity