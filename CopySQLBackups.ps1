<#
    NAME: CopySQLbackups.ps1
    AUTHOR: Andrew Lamarra
    CREATED: 4/30/2015
    LAST UPDATED: 5/1/2015
    
    COMMENTS: This script will look for the latest SQL database backups
        and copy them to another machine.
#>

# Check to see if the V: drive is present
If (Test-Path V:)
{
    # Declaring some variables
    $date = Get-Date
    $temp = '\\172.16.10.117\D$\temp'
    $dest = "$temp\" + $date.Month + '-' + $date.Day + ' Backup'
    $SQLpath = 'V:\SQL_Verification'
    
    # Gather the login credentials
    Write-Host 'Enter login credentials for the GAT machine.'
    Write-Host '(Username does not need to include the domain)'
    $username = Read-Host 'Username'
    $password = Read-Host 'Password' -AsSecureString
    $plainpass = [System.Runtime.InteropServices.Marshal]::`
        PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    # Cache credentials for our network path
    net use $temp /USER:$username $plainpass
    
    # Create the folder that we'll be pasting the backup files into
    New-Item -Path $dest -ItemType Directory

    # Find the second to newest backup files
    # (to avoid copying a file that's currently being written to)
    $fileOR = Get-ChildItem -Path "$SQLpath\FA_PROD_OR_backup*.bak" `
        | Sort-Object LastWriteTime -Descending `
        | Select-Object -Index 1
    $fileCORE = Get-ChildItem -Path "$SQLpath\FA_PROD_CORE_backup*.bak" `
        | Sort-Object LastWriteTime -Descending `
        | Select-Object -Index 1
    
    # Transfer the files
    Write-Host 'Copying the FA_PROD_OR_backup file now...'
    Start-BitsTransfer -Source $fileOR.FullName -Destination $dest
    Write-Host "Complete`n"
    Write-Host 'Copying the FA_PROD_CORE_backup file now...'
    Start-BitsTransfer -Source $fileCORE.FullName -Destination $dest
    Write-Host 'Complete'

    # Remove the stored network path
    net use $temp /delete

} else {
    # If V: drive is not present, then do nothing
    Write-Host 'This SQL server is not hosting the cluster. Please log into the other server.'
}
