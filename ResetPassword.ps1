<#
    NAME: ResetPassword.ps1
    AUTHOR: Andrew Lamarra
    CREATED: 8/20/2015
    
    COMMENTS: This script will reset the local admin password on several servers.
#>

$strcomputers = 'xxxxxx.xxxx.gov','xxxxxx.xxxx.gov' #Redacted

foreach ($computer in $strcomputers)
{
    $admin = [adsi] ("WinNT://" + $computer + "/adminusernameX, user") #Redacted
    $admin.psbase.invoke("SetPassword", "NewPassword")
}
