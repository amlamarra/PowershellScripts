<#
    NAME: SoftwareAudit.ps1
    AUTHOR: Andrew Lamarra
    CREATED: 5/7/2015

    COMMENTS: This script will run through the servers given and provides
              information about software and hotfixes that are installed locally
 #>

# Declare Variables
$date = Get-Date
$filename = "Production_" + $date.month + "_" + $date.year
$filePath = "$env:USERPROFILE\Desktop\$filename.csv"
$servername = 'XXXXXX','XXXXXX','XXXXXX','XXXXXX' #Redacted

# If the file currently exists, delete it
If (Test-Path $filePath) {
    Remove-Item $filePath
}

For ($i=0; $i -lt $servername.Length; $i++) {
    Write-Host 'Retrieving Installed Software Information from ' $servername[$i]

    # Open new PowerShell Session
    $session = New-PSSession -ComputerName $servername[$i]
    
    # Gets installed 32-bit software from the registry
    $data = Invoke-Command -Session $session -ScriptBlock { `
            Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* `
                | Where-Object {$_.DisplayName} } `
        | Select-Object @{Name='Server Name';Expression={$_.PSComputerName}}, @{Name='Description';Expression={$_.DisplayName}}, @{Name='Version';Expression={$_.DisplayVersion}} `
        | Sort-Object Description, ID
    
    # Gets installed 64-bit software from the registry
    $data += Invoke-Command -Session $session -ScriptBlock { `
            Get-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
                | Where-Object {$_.DisplayName} } `
        | Select-Object @{Name='Server Name';Expression={$_.PSComputerName}}, @{Name='Description';Expression={$_.DisplayName}}, @{Name='Version';Expression={$_.DisplayVersion}} `
        | Sort-Object Description, ID
    
    # Exclude any software updates
    $output = $data | Where-Object {$_.Description -notlike '*KB*'}

    # Separator between SOFTWARE section & UPDATES section
    $newRow = New-Object PsObject -Property @{'Server Name'=''; Description=''; Version=''}
    $output += $newRow
    $newRow = New-Object PsObject -Property @{'Server Name'='UPDATES'; Description=''; Version=''}
    $output += $newRow
    $newRow = New-Object PsObject -Property @{'Server Name'='Server Name'; Description='Description'; Version='HotFixID'}
    $output += $newRow

    # Gets all Windows updates
    $output += Get-HotFix -ComputerName $servername[$i] `
        | Select-Object @{Name='Server Name';Expression={$_.PSComputerName}}, Description, @{Name='Version';Expression={$_.HotFixID}} `
        | Sort-Object HotFixID
    
    # If this isn't the last set of output, include a separator
    if ($i -lt $servername.Length-1) {
        $newRow = New-Object PsObject -Property @{'Server Name'=''; Description=''; Version=''}
        $output += $newRow
        $newRow = New-Object PsObject -Property @{'Server Name'='SOFTWARE'; Description=''; Version=''}
        $output += $newRow
        $newRow = New-Object PsObject -Property @{'Server Name'='Server Name'; Description='Description'; Version='Version'}
        $output += $newRow
    }

    # Save the output to the CSV file
    $output | Export-Csv -Path $filePath -NoTypeInformation -Append
    Remove-PSSession $session
}
