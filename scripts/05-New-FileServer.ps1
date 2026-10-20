<#
.SYNOPSIS
    Builds the department file share using the AGDLP model.

.DESCRIPTION
    For every department it creates:
      GG_<Dept>_Users   (Global group, holds accounts or department groups)
      DL_<Dept>_Modify  (Domain Local group, receives the NTFS permission)
    nests GG into DL, creates C:\CompanyData\<Dept> with inheritance removed and
    Modify granted to the DL group only, then publishes C:\CompanyData as the SMB share
    "CompanyData" with access-based enumeration (ABE) enabled.

    Security choices (they differ slightly from a default GUI setup):
      * The share root does NOT inherit from C:\ (so BUILTIN\Users cannot read it).
      * Authenticated Users get "this folder only" read, so mapped drives open and ABE
        can show each user only the folders they can access.
      * Share permissions are broad (Change); NTFS permissions do the real restriction.

.NOTES
    Run on DC01 (or a file server) in an elevated PowerShell session after scripts 01-02.
    Safe to re-run: existing groups, folders and the share are reused/updated.
    Group changes only reach a user after they sign out and back in.

.EXAMPLE
    .\05-New-FileServer.ps1
.EXAMPLE
    .\05-New-FileServer.ps1 -Departments IT,HR,Finance -MemberGroups @{ IT = 'IT-staff' }
#>
[CmdletBinding()]
param(
    [string]$RootPath    = 'C:\CompanyData',
    [string]$ShareName   = 'CompanyData',
    [string[]]$Departments = @('IT', 'HR', 'Finance'),
    # Optional: existing department group to nest into GG_<Dept>_Users (e.g. IT-staff -> GG_IT_Users)
    [hashtable]$MemberGroups = @{ IT = 'IT-staff' }
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$domain   = Get-ADDomain
$domainDN = $domain.DistinguishedName
$netbios  = $domain.NetBIOSName

function Invoke-Icacls {
    param([Parameter(Mandatory)][string[]]$IcaclsArgs)
    & icacls.exe @IcaclsArgs | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "icacls failed: $($IcaclsArgs -join ' ')" }
}

# Well-known SIDs keep the script independent of OS language:
# S-1-5-18 = SYSTEM, S-1-5-32-544 = Administrators, S-1-5-11 = Authenticated Users
$sidSystem = '*S-1-5-18'; $sidAdmins = '*S-1-5-32-544'; $sidAuth = '*S-1-5-11'

# --- 1. File Server role service ---
if (-not (Get-WindowsFeature -Name FS-FileServer).Installed) {
    Install-WindowsFeature -Name FS-FileServer | Out-Null
    Write-Host 'Installed File Server role service.'
} else { Write-Host 'File Server role service already installed.' }

# --- 2. AGDLP groups ---
foreach ($d in $Departments) {
    $gg = "GG_${d}_Users"
    $dl = "DL_${d}_Modify"
    $ou = "OU=$d,$domainDN"

    if (-not (Get-ADGroup -Filter "Name -eq '$gg'")) {
        New-ADGroup -Name $gg -GroupScope Global -GroupCategory Security -Path $ou `
            -Description "AGDLP global group: $d accounts"
        Write-Host "Created group: $gg"
    }
    if (-not (Get-ADGroup -Filter "Name -eq '$dl'")) {
        New-ADGroup -Name $dl -GroupScope DomainLocal -GroupCategory Security -Path $ou `
            -Description "AGDLP domain local group: Modify on $RootPath\$d"
        Write-Host "Created group: $dl"
    }

    # GG -> DL
    Add-ADGroupMember -Identity $dl -Members $gg -ErrorAction SilentlyContinue

    # existing department group -> GG (for example IT-staff -> GG_IT_Users)
    if ($MemberGroups.ContainsKey($d)) {
        $member = $MemberGroups[$d]
        if (Get-ADGroup -Filter "Name -eq '$member'") {
            Add-ADGroupMember -Identity $gg -Members $member -ErrorAction SilentlyContinue
        } else { Write-Warning "Member group '$member' not found; add users to $gg manually." }
    }
}

# --- 3. Root folder: no inheritance from C:\, SYSTEM/Admins full, Authenticated Users list-only ---
New-Item -Path $RootPath -ItemType Directory -Force | Out-Null
Invoke-Icacls @($RootPath, '/inheritance:r')
Invoke-Icacls @($RootPath, '/grant:r', "${sidSystem}:(OI)(CI)F", "${sidAdmins}:(OI)(CI)F", "${sidAuth}:(RX)")

# --- 4. Department folders: only the DL group gets Modify ---
foreach ($d in $Departments) {
    $path = Join-Path $RootPath $d
    New-Item -Path $path -ItemType Directory -Force | Out-Null
    Invoke-Icacls @($path, '/inheritance:r')
    Invoke-Icacls @($path, '/grant:r',
        "${sidSystem}:(OI)(CI)F", "${sidAdmins}:(OI)(CI)F",
        "${netbios}\DL_${d}_Modify:(OI)(CI)M")
    Write-Host "NTFS configured: $path"
}

# --- 5. SMB share with access-based enumeration ---
if (-not (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $ShareName -Path $RootPath `
        -FolderEnumerationMode AccessBased `
        -ChangeAccess 'Authenticated Users' -FullAccess 'BUILTIN\Administrators' | Out-Null
    Write-Host "Created share: \\$env:COMPUTERNAME\$ShareName"
} else {
    Set-SmbShare -Name $ShareName -FolderEnumerationMode AccessBased -Force
    Write-Host "Share exists; access-based enumeration enforced: $ShareName"
}

# --- 6. Summary ---
Get-SmbShare -Name $ShareName | Format-List Name, Path, FolderEnumerationMode
Get-SmbShareAccess -Name $ShareName | Format-Table AccountName, AccessRight -AutoSize
Get-ADGroup -Filter "Name -like 'GG_*' -or Name -like 'DL_*'" |
    Sort-Object Name | Format-Table Name, GroupScope -AutoSize

Write-Host "`nNext: add users to the department groups, then have them SIGN OUT and back in before testing."
Write-Host "Map on the client: net use Z: \\$env:COMPUTERNAME.$($domain.DNSRoot)\$ShareName /persistent:yes"
