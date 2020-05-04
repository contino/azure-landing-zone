function New-MgmtGroup
{
    param(
        [Parameter(Mandotory = $true)]
        [string]$GroupName,
        [Parameter(Mandatory = $false)]
        [string]$ParentName
    )

    $mgmtGroup = Get-AzManagementGroup -GroupName $GroupName -ErrorAction SilentlyContinue
    if ($null -eq $mgmtGroup){
        if ($null -eq $ParentName) {
        New-AzManagementGroup -GroupName $GroupName
        }
        else {
            $parentObject = Get-AzManagementGroup -GroupName $ParentName
            New-AzManagementGroup -GroupName $GroupName -ParentObject $parentObject

    }
    }
}