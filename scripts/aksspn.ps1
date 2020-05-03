param (
[Parameter(Mandatory=$true)]
[string]$KVName,
[Parameter(Mandatory=$true)]
[string]$spnName
)


$spn_exist = Get-AzADApplication -DisplayName $spnName -ErrorAction SilentlyContinue

if($null -eq $spn_exist){
    $sp = New-AzADServicePrincipal -DisplayName $spnName

    Write-Host "Adding App ID in Keyvault"
    $appId = $sp.ApplicationId | ConvertTo-SecureString -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $KVName -Name "aksspid" -SecretValue $appId

    Write-Host "Adding AppID Secret"
    Set-AzKeyVaultSecret -VaultName $KVName -Name "aksspsecret" -SecretValue $sp.Secret
}
else
{
    Write-Host "SPN Exists"
}