param (
[Parameter(Mandatory=$true)]
[string]$keyvaultName,
[Parameter(Mandatory=$true)]
[string]$spnName
)
$spn_exist = Get-AzADApplication -DisplayName $spnName -ErrorAction SilentlyContinue

if($null -eq $spn_exist){
    $sp = New-AzADServicePrincipal -DisplayName $spnName

    #$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
    #$UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    Write-Host "Adding App ID in Keyvault"
    $appId = $sp.ApplicationId | ConvertTo-SecureString -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyvaultName -Name "aksspid" -SecretValue $appId

    Write-Host "Adding AppID Secret"
    Set-AzKeyVaultSecret -VaultName $keyvaultName -Name "aksspsecret" -SecretValue $sp.Secret
}