# FILE NAME: Security_Groups.ps1
# PURPOSE: Lists all groups & members of each group in the Security_Groups OU
#          Will not list groups from sub-OUs
# AUTHOR: SSgt Andrew Lamarra

# Setting the path variable
$path = "$env:USERPROFILE\Desktop\Groups.csv"

# If the file already exists on the user's desktop, delete it first
If (Test-Path $path) { Remove-Item $path }

# Saves the list of groups to a variable as an object
# Change SearchScope to 2 if you want it to get groups from sub-OUs as well
$Groups = Get-ADGroup -Filter * -Properties * -SearchScope 1 `
    -SearchBase "OU=Security_Groups,OU=XXXXX,OU=XXXXX,OU=XXX,DC=XXX,DC=XX,DC=af,DC=mil" `
    | Sort-Object Name

# Stepping through each of the Group objects
Foreach ($group in $Groups) {
    # Output the name of the group first
    Out-File -FilePath $path -InputObject $group.Name -Append

    # Saving the list of group members to an array & sorting alphabetically
    $members = $group.Members | Sort-Object

    # Stepping through each of the elements in the members array
    Foreach ($mem in $members) {
        # Each member displays the Distinguished Name
        # This gets rid of all unnecessary characters
        $name = $mem -replace ",.*" -replace ".*="

        # Oupt the name to the CSV file
        Out-File -FilePath $path -InputObject $name -Append
    }
    # Adding a space before the next Group name is listed
    Out-File -FilePath $path -InputObject '' -Append
} 
