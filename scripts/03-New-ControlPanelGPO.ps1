<#
.SYNOPSIS
    Creates the IT-Block-ControlPanel GPO, links it to the IT OU and applies
    security filtering so only IT-ControlPanel-Restricted members are affected.
.NOTES
    Run on DC01. Equivalent to the GPMC steps in docs/group-policy-configuration.md.
#>
[CmdletBinding()]
param(
    [string]$GpoName     = 'IT-Block-ControlPanel',
    [string]$TargetOU    = 'IT',
    [string]$FilterGroup = 'IT-ControlPanel-Restricted'
)

$ErrorActionPreference = 'Stop'
Import-Module GroupPolicy, ActiveDirectory

$ouDN = "OU=$TargetOU,$((Get-ADDomain).DistinguishedName)"

if (-not (Get-GPO -Name $GpoName -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GpoName | Out-Null
}

# User Configuration > Admin Templates > Control Panel >
# "Prohibit access to Control Panel and PC settings" = Enabled
Set-GPRegistryValue -Name $GpoName `
    -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' `
    -ValueName 'NoControlPanel' -Type DWord -Value 1 | Out-Null

# Link to the OU (skip if already linked)
$links = (Get-GPInheritance -Target $ouDN).GpoLinks.DisplayName
if ($links -notcontains $GpoName) {
    New-GPLink -Name $GpoName -Target $ouDN -LinkEnabled Yes | Out-Null
}

# Security filtering: apply only to the restricted group...
Set-GPPermission -Name $GpoName -TargetName $FilterGroup -TargetType Group -PermissionLevel GpoApply | Out-Null
# ...and keep Read-only for Authenticated Users (needed for user GPO processing since MS16-072)
Set-GPPermission -Name $GpoName -TargetName 'Authenticated Users' -TargetType Group -PermissionLevel GpoRead -Replace | Out-Null

Get-GPPermission -Name $GpoName -All | Format-Table Trustee, Permission -AutoSize
