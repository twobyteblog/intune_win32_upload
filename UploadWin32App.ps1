<#
.SYNOPSIS
  Automates the generation of an .intunewin package and subsequent upload to Microsoft Intune. Reads all required values from JSON file.
.DESCRIPTION

.REQUIREMENTS

  Install-Module -Name IntuneWin32App -Scope CurrentUser
  Install-Module Microsoft.Graph.Intune -Scope CurrentUser

.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Inundation.ca
  
.EXAMPLE
  ./UploadWin32App.ps1

#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

param (
    [string]$Path
)

#Set Error Action to Silently Continue
$ErrorActionPreference = "Stop"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Connection details for connecting into Microsoft Graph.
# https://learn.microsoft.com/en-us/powershell/microsoftgraph/app-only?view=graph-powershell-1.0

$TenantID = 
$ClientID = 
$ClientSecret = 
$IntuneWinExe = 

# Default Settings
$DetectFile = "detect.ps1" # Name of detection script.
$ConfigFile = "config.json" # Name of configuratiuon file.

#-----------------------------------------------------------[Functions]------------------------------------------------------------

# Function to generate the required .intunewim file for upload to Microsoft Intune.

function Generate-App {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory)]
        [string]$source,
        [string]$executable,
        [string]$output
    )

    # Validate directory .intunewin will be saved.
    if (!(Test-Path -Path $output)) {
        Write-Host "Error: Unable to validate location of executable $output. Exiting." -ForegroundColor Red
        exit
    }

    # Generate .intunewin file
    try {
        & $intuneWinExe -c $source -s $executable -o $output -q

    } catch {
        Write-Host "Error: Failed to generate .intunewin file." -ForegroundColor Red
        $_
    }

}

# Function to upload app into Microsoft Intune.

function Upload-App {

    [CmdletBinding()]

    param ( 
        [Parameter (Mandatory)]
        [array]$application
    )

    # Generate full display name.
    $DisplayName = "$($application.Name) Ver. $($application.CurrentVersion)"

    # Create return code.
    if ($app.ReturnCode) {
        $ReturnCode = New-IntuneWin32AppReturnCode -ReturnCode $application.ReturnCode -Type $application.ReturnValue
    }

    # Create requirement rule.
    $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture $application.RequirementArchitecture -MinimumSupportedWindowsRelease $application.RequirementOS

    # Create detection rule.
    $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $application.Detection -EnforceSignatureCheck $false -RunAs32Bit $false

    $params = @{
        FilePath = $application.Package
        DisplayName = $DisplayName
        Description = $application.Description
        AppVersion = $application.CurrentVersion
        Publisher = $application.Publisher
        InstallExperience = $application.InstallExperience
        MaximumInstallationTimeInMinutes = $application.InstallationTime
        RestartBehavior = $application.DeviceRestartBehaviour
        ReturnCode = $ReturnCode
        RequirementRule = $RequirementRule 
        DetectionRule = $DetectionRule
        InstallCommandLine = $application.InstallCommand
        UninstallCommandLine = $application.UninstallCommand
    }

    # Remove any empty keys of the $params object prior to upload.
    $ActiveParams = @{}

    foreach ($key in $params.Keys) {
        $value = $params[$key]

        if (![string]::IsNullOrWhiteSpace($value)) {
            $ActiveParams[$key] = $value
        }
    }

    try {
        # Upload app.
        Add-IntuneWin32App @ActiveParams | Out-Null 3>$null
        Write-Host "$($App.Name): App successfully uploaded." -ForegroundColor Green

    } catch{
        Write-Host "Error occurred when uploading: $($app.Name)." -ForegroundColor Red
        $_
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Import IntuneWin32App module.
Import-Module -Name IntuneWin32App

# Log into Microsoft Graph.
Connect-MSIntuneGraph -ClientID $clientId -TenantId $tenantId -ClientSecret $clientSecret | Out-Null

if (-not(Test-Path $Path)) {
    Write-Host "Provided path is invalid. Exiting." -ForegroundColor Red
    Exit 1
}

# Import package information from JSON.

$ConfigFilePath = Join-Path -Path $Path -ChildPath $ConfigFile

if (Test-Path $ConfigFilePath) {

    try {
        $App = Get-Content -Raw $ConfigFilePath | ConvertFrom-Json
    } catch {
        Write-Host "Unable to successfully import JSON file. Exiting" -ForegroundColor Red
        Exit 1
    }

}

# Generate .intunewin file.

$SourcePath = Join-Path -Path $Path -ChildPath "Source" # Path to application package.
$ExecutablePath = Get-ChildItem -Path $SourcePath -Filter $($App.IntuneWINExecutable) -Recurse | Select-Object -First 1 # Path to executable.
$OutputPath = "$Env:LocalAppData\Temp" # Output for .intunewin file.

Write-Host "$($App.Name): Generating .intunewin file." -ForegroundColor Green
Generate-App -Source $SourcePath -Executable $ExecutablePath -Output $OutputPath

$PackageName = "$($ExecutablePath.Basename).intunewin"
$PackagePath = Join-Path -Path $OutputPath -ChildPath $PackageName

if (Test-Path $PackagePath) {
    $App | Add-Member -MemberType NoteProperty -Name "Package" -Value $PackagePath
}

# Upload app to Microsoft 365.

$DetectionPath = Get-ChildItem -Path $Path -Filter $DetectFile -Recurse | Select-Object -First 1
$App | Add-Member -MemberType NoteProperty -Name "Detection" -Value $DetectionPath.FullName

Write-Host "$($App.Name): Uploading app to Microsoft Intune." -ForegroundColor Green
Upload-App -Application $App

