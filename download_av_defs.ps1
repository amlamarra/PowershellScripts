<#
    NAME:     download_av_defs.ps1
    AUTHOR:   Andrew Lamarra
    CREATED:  Feb 8, 2017
    COMMENTS: Downloads the latest McAfee & ClamAV virus definitions
              Compatible with PowerShell 3.0 and above
#>

# Get the source content of the page and save to a file
$mav_url = 'http://download.nai.com/products/DatFiles/4.x/NAI/'
$R = Invoke-WebRequest $mav_url
$tempfile = $PSScriptRoot + '\content.txt'
$R.Content | Out-File $tempfile

# Set the date variable to the current date (matching the format of the site)
$date = Get-Date -Format dd-MMM-yyyy

# Find the latest date on the site if it's not the current day
$day = 0
while (-Not (Get-Content $tempfile | Select-String -Pattern "(exe.*$date)")) {
    $day -= 1
    $date = Get-Date (Get-Date).AddDays($day) -Format dd-MMM-yyyy
}

# Strip out a line that has the current version number
Set-Content $tempfile -Value (Get-Content $tempfile | Select-String -Pattern "(exe.*$date)")

# Strip text that is not the version number and save to a variable
$version = (Get-Content $tempfile).Split(('HREF="','xdat.exe"'),'None')[1]
Remove-Item $tempfile

# Setting some variables
$mav_exe = $mav_url + $version + 'xdat.exe'
$mav_exe_out = $PSScriptRoot + '\' + $version + 'xdat.exe'
$mav_zip = $mav_url + 'avvepo' + $version + 'dat.zip'
$mav_zip_out = $PSScriptRoot + '\' + 'avvepo' + $version + 'dat.zip'
$clam_cvd = "http://database.clamav.net/daily.cvd"
$clam_cvd_out = $PSScriptRoot + '\daily.cvd'

# Download the 3 files to the same directory as the script
(New-Object System.Net.WebClient).DownloadFile($mav_exe, $mav_exe_out)
(New-Object System.Net.WebClient).DownloadFile($mav_zip, $mav_zip_out)
(New-Object System.Net.WebClient).DownloadFile($clam_cvd, $clam_cvd_out)

# The Start-BitsTransfer cmdlet does not work if the user is not logged in
#Start-BitsTransfer -Source $mav_exe -Destination $mav_exe_out
#Start-BitsTransfer -Source $mav_zip -Destination $mav_zip_out
#Start-BitsTransfer -Source $clam_cvd -Destination $clam_cvd_out
