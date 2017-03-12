# FILENAME: HotFixFind.ps1
# PURPOSE: Identify which computers are missing which updates
# AUTHOR: SSgt Andrew Lamarra

# Declaring variables
$RequiredKBs = Get-Content -Path C:\script\updates.txt
$computers = Get-Content -Path C:\script\computers.txt
$path1 = 'C:\script\InstalledHofixes.txt'
$path2 = 'C:\script\Trimmed.txt'
$final = 'C:\script\Final.txt'

# Creating the final file to overwrite any content
Out-File -FilePath $final

# Step through the entire process once for each computer
For ($c = 0; $c -lt $computers.Length; $c++) {
    # Get list of all hotfixes installed on the current computer & output to a file
    Get-HotFix -ComputerName $computers[$c] `
        | Select-Object HotFixID `
        | Out-File $path1
    
    # Trim everything out that's not a KB (including extra spaces) & output to a file
    Get-Content $path1 `
        | Where-Object {$_ -match "^KB"} `
        | ForEach-Object {$_.Trim()} `
        | Out-File $path2
    
    # The computer name is the first line
    Out-File -FilePath $final -InputObject $computers[$c] -Append
    
    # Save the contents of the installed hotfixes to an array
    $InstalledKBs = Get-Content $path2
    
    # Stepping through each of the required KBs
    For ($x = 0; $x -lt $RequiredKBs.Length; $x++) {
        # Stepping through each of the installed KBs
        For ($y = 0; $y -lt $InstalledKBs.Length; $y++) {
            # If there's a match, move onto the next required KB
            If ($RequiredKBs[$x] -eq $InstalledKBs[$y]) {
                $x++
                $y = 0
            }
        }
        # If none of the installed KBs match the required KB, add it to Final.txt
        Out-File -FilePath $final -InputObject $RequiredKBs[$x] -Append
    }
    # Adding an extra line break before the next computer's output
    Out-File -FilePath $final -InputObject `n -Append
}
# Deleting the files that were only temporarily needed
Remove-Item -Path $path1
Remove-Item -Path $path2 
