# This script is intended to update a DNS record in a specific DNSZone
# Note this script will delete the existing "A" (IPv4) record and create a new "A" record to replace it
# You will have to update the script to accomodate "AAAA" (Ipv6) records if deeemed neccesary

$RemoteSession = New-PSSession -ComputerName dc1.example.local -Credential (Get-Credential example.local\$env:USERNAME)

Invoke-Command -Session $RemoteSession -ScriptBlock {
    Import-Module DnsServer
    $DNSZone = if (($prompt = Read-Host -Prompt "Enter LookupZone [example.local]") -eq "") {"example.local"} else {$prompt}

    Write-Host "Current DNS Setting" -foregroundcolor Yellow
    Get-DnsServerResourceRecord -ZoneName $DNSZone -RRType "A" | Format-Table -wrap -autosize | Out-String

    $Hostname = Read-Host -Prompt "Enter the HostName"
    $IPAddress = Read-Host -Prompt "Enter the IP address to assign to DNS HostName (e.g. '8.8.8.8')"

    Remove-DnsServerResourceRecord -Force -Confirm:$false -ZoneName $DNSZone -RRtype A -Name $Hostname
    Add-DnsServerResourceRecord -ZoneName $DNSZone -A -Name $Hostname -AllowUpdateAny -IPv4Address $IPAddress
    Write-Host "Updated DNS Setting" -foregroundcolor Green
    Get-DnsServerResourceRecord -ZoneName $DNSZone -RRType "A" | Format-Table -wrap -autosize | Out-String
}
Remove-PSSession $RemoteSession
Read-Host "Enter any key to exit"