<#
.SYNOPSIS
    Joins CLIENT01 to the lab domain. Run in an elevated session on the client.
.NOTES
    Set the client DNS to the DC first (see 00-Set-StaticIP.ps1).
#>
[CmdletBinding()]
param(
    [string]$DomainName = 'lab.example.com',
    [string]$DnsServer  = '192.168.163.10'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Connection -ComputerName $DnsServer -Count 2 -Quiet)) {
    throw "Cannot reach $DnsServer. Check that both VMs are on the same VMnet1 host-only network."
}
Resolve-DnsName -Name $DomainName -Server $DnsServer -ErrorAction Stop | Out-Null

Add-Computer -DomainName $DomainName -Credential (Get-Credential -Message "Domain account allowed to join computers") -Restart
