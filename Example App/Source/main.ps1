<#
.SYNOPSIS
  Disables Adobe Acrobat's new built-in AI features.

.DESCRIPTION
  Disables Adobe's AI integration as it is not in compliance with our data storage policies.

.PARAMETER <Parameter_Name>
  -Install - Deploy the configuration.
  -Uninstall - Remove the configuration.
.INPUTS
  None.
.OUTPUTS
  Log file stored in C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\DisableAdobeAcrobatAI.log
.NOTES
  Version:        1.0
  Author:         inundation.ca
  Creation Date:  March 14th, 2024
  
.EXAMPLE
  ./main.ps1 -Install
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

param (
    [switch]$Install,
    [switch]$Uninstall
)

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$ScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\"
$sLogName = "DisableAdobeAcrobatAI.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Set-RegistryKey {
    param(
        [string]$Path,
        [string]$Name,
        [string]$Value,
        [string]$Type
    )

    try {

        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
            New-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
        } else {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
        }
    }
    
    catch {
        Write-Host "Unable to successfully set $Path\$Name with value $Value of type $Type."
        Exit 1
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Start-Transcript -Path $sLogFile -Append

# If both -install and -uninstall flags set, exit.

if ( ($Install) -and ($Uninstall) ) {

    Write-Host "Both -Install and -Uninstall set, only one argument may be used at a time. Exiting."
    Exit 1
}

if ( $Install ) {

    Set-RegistryKey -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown" -Name "bEnableGentech" -Value "0" -Type "DWORD"

} elseif ($Uninstall) {

    Set-RegistryKey -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown" -Name "bEnableGentech" -Value "1" -Type "DWORD"

} else {

    Write-Host "No -install or -uninstall flag provided. Exiting."
    Exit 1

}

Stop-Transcript