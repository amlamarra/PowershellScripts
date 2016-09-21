<#
    NAME: CreateADaccounts.ps1
    AUTHOR: Andrew Lamarra
    CREATED: 7/15/2015
    
    COMMENTS: This script will add a bunch of accounts to AD from a CSV file.
#>

Import-Csv "C:\Users\Administrator\Desktop\Adding Users\final.csv" | `
ForEach-Object {
    $UPN = $_."SAMAccountName" + '@' + (Get-ADDomain).DNSRoot
    $path = "OU=" + $_."MemberOf" + "," + (Get-ADDomain).DistinguishedName
    New-ADUser  -Name $_."DisplayName" `
                -DisplayName $_."DisplayName" `
                -SamAccountName $_."SAMAccountName" `
                -GivenName $_."GivenName" `
                -Initials $_."Initials" `
                -Surname $_."Surname" `
                -Description $_."Description" `
                -Company $_."Company" `
                -Path $path `
                -UserPrincipalName $UPN `
                -AccountPassword (ConvertTo-SecureString "Bure@u123" -AsPlainText -Force) `
                -ChangePasswordAtLogon $true `
                -Enabled $true `
                -OtherAttributes @{'TelephoneNumber'=$_."TelephoneNumber"}
    # Add-ADGroupMember "Domain Admins" $_."samAccountName"
}
