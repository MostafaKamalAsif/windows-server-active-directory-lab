<#
.SYNOPSIS
    Creates the OU structure, security groups and users defined in data/users.csv.
.NOTES
    Idempotent: existing objects are skipped. Run on DC01 after promotion.
    The initial password is requested interactively; users must change it at first logon.
#>
[CmdletBinding()]
param(
    [string]$CsvPath = (Join-Path $PSScriptRoot '..\data\users.csv'),
    [string[]]$OUs   = @('IT', 'HR', 'Finance'),
    [string[]]$Groups = @('IT-staff', 'IT-ControlPanel-Restricted'),
    [string]$GroupOU = 'IT'
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$domainDN  = (Get-ADDomain).DistinguishedName
$domainDNS = (Get-ADDomain).DNSRoot

# --- OUs ---
foreach ($ou in $OUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $domainDN -SearchScope OneLevel)) {
        New-ADOrganizationalUnit -Name $ou -Path $domainDN -ProtectedFromAccidentalDeletion $true
        Write-Host "Created OU: $ou"
    } else { Write-Host "OU exists:  $ou" }
}

# --- Security groups ---
foreach ($g in $Groups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$g'")) {
        New-ADGroup -Name $g -GroupScope Global -GroupCategory Security -Path "OU=$GroupOU,$domainDN"
        Write-Host "Created group: $g"
    } else { Write-Host "Group exists:  $g" }
}

# --- Users ---
$initialPassword = Read-Host -Prompt 'Initial password for new users' -AsSecureString

foreach ($u in Import-Csv -Path $CsvPath) {
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'")) {
        New-ADUser `
            -SamAccountName $u.SamAccountName `
            -UserPrincipalName "$($u.SamAccountName)@$domainDNS" `
            -Name "$($u.GivenName) $($u.Surname)" `
            -GivenName $u.GivenName -Surname $u.Surname `
            -Path "OU=$($u.OU),$domainDN" `
            -AccountPassword $initialPassword `
            -ChangePasswordAtLogon $true `
            -Enabled $true
        Write-Host "Created user: $($u.SamAccountName)"
    } else { Write-Host "User exists:  $($u.SamAccountName)" }

    foreach ($g in ($u.Groups -split ';' | Where-Object { $_ })) {
        Add-ADGroupMember -Identity $g -Members $u.SamAccountName -ErrorAction SilentlyContinue
    }
}
