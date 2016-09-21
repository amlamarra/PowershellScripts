<#
    NAME:     DataCallOutput_Email.ps1
    AUTHOR:   Andrew Lamarra
    DATE:     1/15/2016

    COMMENTS: This script will take the output of a regularly-scheduled data call
              (from an xlsx file) and email it to myself on another machine.
#>

$path = "\\hostname\c$\Users\amlamarra\Desktop\Shared\Submission Exdended Data with Duplicate Document Types.xlsx"
Write-Host "Begin program...\n"
If (Test-Path $path)
{
    Write-Host "Emailing files...\n"
    $lastwrite = Get-ChildItem -Path $path | Select-Object LastWriteTime | Get-Date
    $date = Get-Date

    If ($date -lt $lastwrite.AddDays(7))
    {
        $Outlook = New-Object -ComObject Outlook.Application
        $Mail = $Outlook.CreateItem(0)
        $Mail.To = "xxxx@xxxx.xxx" #Redacted
        $Mail.Subject = "Weekly Data Call"
        $Mail.Body = "Attach this file to the 'Submission Extended Data Call' email template and send it."
        $Mail.Attachments.Add($path)
        $Mail.Send()
    }
} else {
    Write-Host "File not found...\n"
}
