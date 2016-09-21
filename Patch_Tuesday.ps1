<#
    NAME:     Patch_Tuesday.ps1
    AUTHOR:   Andrew Lamarra
    DATE:     1/16/2015
    MODIFIED: 5/13/2015

    COMMENTS: This script will check certain servers for any hotfix installed since
              the beginning of the current month and saves the data to a CSV file
              sorted by install date in ascending order on the current user's desktop.
#>

$date = Get-Date
$filename = 'McLean_' + $date.Month + '_' + $date.Year
$filePath = "$env:USERPROFILE\Desktop\$filename.csv"
$servername = @('','','','') #Redacted

If (Test-Path $filePath) { Remove-Item $filePath }

$data = @()
For ($i=0; $i -lt $servername.Length; $i++) {
    'Retrieving Installed Software Information from ' + $servername[$i]

    #Gets Hotfix info installed this month with importance of "Important", selects 4 columns & sorts them
    $data = Get-HotFix -ComputerName $servername[$i] `
    | Where-Object {$_.InstalledOn -ge $date.AddDays(-24) -and $_.Description -ne 'Update'} `
    | Select-Object @{Name="Server Name";Expression={$_.PSComputerName}}, Description, HotFixID, @{Name="Install Date";Expression={$_.InstalledOn.ToShortDateString()}} `
    | Sort-Object HotFixID, InstalledOn
    
    if ($data.Count -gt 0) {
        #This separates the output by Server Name
        if ($i -lt $servername.Length-1) {
            $newRow = New-Object PsObject -Property @{'Server Name'='';Description='';HotFixID='';'Install Date'=''}
            $data += $newRow
            $newRow = New-Object PsObject -Property @{'Server Name'='Server Name';Description='';HotFixID='HotFixID';'Install Date'='Install Date'}
            $data += $newRow
        }
        $data | Export-Csv $filePath -NoTypeInformation -Append
    }
}
