<#
    NAME: RemoveADaccounts.ps1
    AUTHOR: Andrew Lamarra
    CREATED: 7/30/2015
    
    COMMENTS: This script will remove a bunch of accounts to AD.
#>

$OUnits = Get-ADOrganizationalUnit -Filter *
foreach ($ou in $OUnits)
{
    $base = "OU="+$ou.name+",DC=xxxx,DC=xxx" #Redacted
    $Users = Get-ADUser -Filter * -SearchBase $base
    foreach ($u in $Users)
    {
        Remove-ADUser $u.SAMAccountName
    }
}
