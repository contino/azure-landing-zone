function New-MgmtGroup
{

    $file = (Get-ChildItem -Path "./mgmtGroup" | Where-Object {$_.Extension -eq ".json"})
    $loadVars = Get-Content -Path $file.FullName | ConvertFrom-Json
    $mgmtGroups = (Get-AzManagementGroup).DisplayName

    foreach($obj in $loadVars.MgmtGroup.GroupName){
        if ($mgmtGroups -notcontains $obj.name) {
            if($obj.parent -eq $null) {
                Write-Host "Creating New Management Group $($obj.name)"
                try{
                    New-AzManagementGroup -GroupName $obj.name -ErrorAction Stop
                }
                catch {
                    Write-Host $_.Exception.Message
                }


             if($obj.subscriptionId -ne $null) {
                 Write-Host "Moving $($obj.subscriptionName) to $($obj.Name)"
                 New-AzManagementGroupSubscription -GroupName $obj.name -SubscriptionId $obj.subscriptionId

             }
            }
            else
            {
                $mgmtGroups = (Get-AzManagementGroup).DisplayName
                if($mgmtGroups -notcontains $obj.parent) {
                    Write-Host "Creating Parent Management Group"
                    try{
                        New-AzManagementGroup -GroupName $obj.name
                    }
                    catch  {
                        Write-Host $_.Exception.Message
                    }
                }
                Write-Host "Creating New Management Group Child"
                $parentObject = Get-AzManagementGroup -GroupName $obj.parent
                try
                {
                    New-AzManagementGroup -GroupName $obj.Name -ParentObject $parentObject
                }
                catch
                {
                    Write-Host $_.Exception.Message
                }


                if($obj.subscriptionId -ne $null) {
                    Write-Host "Moving $($obj.subscriptionName) to $($obj.Name) Group"
                    New-AzManagementGroupSubscription -GroupName $obj.name -SubscriptionId $obj.subscriptionId

                }
            }
        }

    }
}

New-MgmtGroup