<#
.SYNOPSIS
    Installs AD DS + DNS and promotes this server to the first DC of a new forest.
.NOTES
    Run on DC01 in an elevated PowerShell session. The server reboots automatically.
    The DSRM password is requested interactively and is never stored in this repo.
#>
[CmdletBinding()]
param(
    [string]$DomainName  = 'lab.example.com',
    [string]$NetbiosName = 'LAB'
)

$ErrorActionPreference = 'Stop'

Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

$dsrm = Read-Host -Prompt 'Enter DSRM (Safe Mode) administrator password' -AsSecureString

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetbiosName `
    -ForestMode WinThreshold `
    -DomainMode WinThreshold `
    -InstallDns `
    -SafeModeAdministratorPassword $dsrm `
    -Force
