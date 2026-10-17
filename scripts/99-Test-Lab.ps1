<#
.SYNOPSIS
    Quick PASS/FAIL health check for the lab. Run on the client or the DC.
#>
[CmdletBinding()]
param(
    [string]$DomainName = 'lab.example.com',
    [string]$DcName     = 'dc01',
    [string]$DcIP       = '192.168.163.10'
)

$results = @()
function Test-Step([string]$Name, [scriptblock]$Check) {
    try   { $ok = [bool](& $Check) }
    catch { $ok = $false }
    $script:results += [pscustomobject]@{ Check = $Name; Result = $(if ($ok) { 'PASS' } else { 'FAIL' }) }
}

Test-Step 'DC reachable by ping'            { Test-Connection $DcIP -Count 2 -Quiet }
Test-Step 'DC A record resolves to DC IP'   { (Resolve-DnsName "$DcName.$DomainName" -Server $DcIP -Type A).IPAddress -contains $DcIP }
Test-Step 'No unexpected A records for DC'  { @(Resolve-DnsName "$DcName.$DomainName" -Server $DcIP -Type A).Count -eq 1 }
Test-Step 'LDAP SRV record present'         { Resolve-DnsName "_ldap._tcp.dc._msdcs.$DomainName" -Server $DcIP -Type SRV }
Test-Step 'DC locator (nltest) succeeds'    { nltest /dsgetdc:$DomainName 2>&1 | Select-String 'DC: ' }
Test-Step 'LDAP port 389 open'              { (Test-NetConnection $DcIP -Port 389 -WarningAction SilentlyContinue).TcpTestSucceeded }

$results | Format-Table -AutoSize
if ($results.Result -contains 'FAIL') { exit 1 }
