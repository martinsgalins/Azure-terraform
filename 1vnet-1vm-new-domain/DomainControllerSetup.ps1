[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$DomainName,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$DSRM
)

$password = ConvertTo-SecureString -AsPlainText $DSRM -Force

install-windowsfeature AD-Domain-Services -IncludeManagementTools

Install-ADDSForest `
-DomainName $DomainName `
-SafeModeAdministratorPassword $password `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true