# Title:       Blackhole-Domains.ps1
# Description: Run this on a Windows DNS server to blackhole a list of domains
# Author:      Andrew Lamarra
# Created:     Sept 25, 2019

$hostname = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
$domains = Get-Content -Path $PSScriptRoot\domains.txt

if ((gwmi win32_computersystem).partofdomain -eq $true) {
    foreach ($domain in $domains) {
        Add-DnsServerPrimaryZone -ComputerName $hostname -Name $domain -ReplicationScope Forest
        Add-DnsServerResourceRecordA -ComputerName $hostname -ZoneName $domain -IPv4Address 127.0.0.1 -Name '.'
    }
} else {
    foreach ($domain in $domains) {
        Add-DnsServerPrimaryZone -ComputerName $hostname -Name $domain -ZoneFile "$domain.dns"
        Add-DnsServerResourceRecordA -ComputerName $hostname -ZoneName $domain -IPv4Address 127.0.0.1 -Name '.'
    }
}
