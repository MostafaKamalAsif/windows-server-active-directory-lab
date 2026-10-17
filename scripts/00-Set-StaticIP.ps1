<#
.SYNOPSIS
    Sets a static IPv4 address and DNS server on a lab VM.
.EXAMPLE
    # On DC01 (DNS points to itself)
    .\00-Set-StaticIP.ps1 -InterfaceAlias "Ethernet0" -IPAddress 192.168.163.10 -DnsServer 192.168.163.10
.EXAMPLE
    # On CLIENT01 (DNS points to the DC)
    .\00-Set-StaticIP.ps1 -InterfaceAlias "Ethernet0" -IPAddress 192.168.163.20 -DnsServer 192.168.163.10
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InterfaceAlias,
    [Parameter(Mandatory)][string]$IPAddress,
    [Parameter(Mandatory)][string]$DnsServer,
    [int]$PrefixLength = 24
)

$ErrorActionPreference = 'Stop'

# Remove any existing IPv4 address so the script can be re-run safely
Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Remove-NetIPAddress -Confirm:$false

New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength | Out-Null
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DnsServer

Get-NetIPConfiguration -InterfaceAlias $InterfaceAlias
