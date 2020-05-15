<#
.SYNOPSIS
    Set a users Teams Preference
.DESCRIPTION
    This script will change the the users Teams configuration file, so the client behaves as requested by the administrator.
.INPUTS
    The following switches are available:
    -openAsHidden          (minimizes Teams to systray on startup)
    -disableAutoStart      (Stops Teams frostarting with the OS)
    -registerAsIMProvider  (Makes Teams the default Instant Messaging Provider for the user)
    -exitOnClose           (Makes the Teams client exit when the main windows is closed)
.OUTPUTS
    A log file called Set-UserTeamsPreference_Script-log.txt is written to the users own TEMP folder at each execution of the script (overwriting the previous log).
.NOTES
    NAME: Set-UserTeamsPreference.ps1
    VERSION: 2005a
    PREREQ:  Make sure Teams is installed as the user before running!
    Coded for readability!
    COPYRIGHT:
    @michael_mardahl / https://www.iphase.dk
    Licensed under the MIT license.
    Please credit me if you fint this script useful and do some cool things with it.
    Thanks go out to James Rankin https://james-rankin.com/articles/microsoft-teams-on-citrix-xenapp/ for the code inspiration.
    A belated thanks goes out to @mwbengtsson for figuring out the imProvider registry keys.
.EXAMPLE
    Run the script as is in the users context, to set defaults
.EXAMPLE
    Make teams start minimized to systray and register as an IM provider
    Set-UserTeamsPreference.ps1 -openAsHidden -registerAsIMProvider
#>

#Requires -Version 5.0

# Parameters that are accepted by the script, none are required.
PARAM(
    [switch]$openAsHidden,
    [switch]$disableAutoStart,
    [switch]$registerAsIMProvider,
    [switch]$exitOnClose
)

#region Delcarations ######################################################################################

# Enabling verbose output for our log 
$VerbosePreference = "Continue"

# The users Teams configuration file
$configFile = "$ENV:APPDATA\Microsoft\Teams\desktop-config.json"

#endregion Declarations

#region Execute ###########################################################################################

# Logging any errors to the users temp folder
Start-Transcript -Path "$env:TEMP\Set-UserTeamsPreference_Script-log.txt"
Write-Output "Modifying the users Teams client..."

#Closing Teams just in case (sorry users!)
Write-Verbose "Killing any running Teams processes..."
Stop-Process -Name Teams -Force -ErrorAction SilentlyContinue

# Load the file data into a variable
Write-Verbose "Fetching the contents of $configFile"
try {
    $fileBuffer = Get-Content $configFile -ErrorAction Stop
} 
catch {
    Write-Error "Could not fetch the users Teams config file! Make sure Teams is installed!"
    Stop-Transcript
    exit 1
}

### Modifying the variable so Teams beahves as dictated by the specified commandline parameters (or lack thereof)

# Hidden option
if($openAsHidden) {
    Write-Verbose '1 - Enabling the "openAsHidden" option...'
    $fileBuffer = $fileBuffer -replace '"openAsHidden":false', '"openAsHidden":true'
} else { 
    Write-Verbose '1 - Disabling the "openAsHidden" option...'
    $fileBuffer = $fileBuffer -replace '"openAsHidden":true', '"openAsHidden":false'
}

# Autostart option
if($disableAutoStart) {
    Write-Verbose '2 - Disabling the "openAtLogin" option...'
    $fileBuffer = $fileBuffer -replace '"openAtLogin":true', '"openAtLogin":false'
} else { 
    Write-Verbose '2 - Enabling the "openAtLogin" option...'
    $fileBuffer = $fileBuffer -replace '"openAtLogin":false', '"openAtLogin":true'
}

# IM Provider option
if($registerAsIMProvider) {
    Write-Verbose '3 - Enabling the "registerAsIMProvider" option...'
    $fileBuffer = $fileBuffer -replace '"registerAsIMProvider":false', '"registerAsIMProvider":true'
    New-ItemProperty -Path "HKCU:\SOFTWARE\IM Providers" -Name DefaultIMApp -Value Teams -PropertyType STRING -Force -ErrorAction SilentlyContinue
} else {
    Write-Verbose '3 - Disabling the "registerAsIMProvider" option...'
    $fileBuffer = $fileBuffer -replace '"registerAsIMProvider":true', '"registerAsIMProvider":false'
    $imProviders = "HKCU:\SOFTWARE\IM Providers"
    $teamsIMProvider = "HKCU:\SOFTWARE\IM Providers\Teams"
    if (Test-Path -Path $teamsIMProvider) {
        $previousDefaultIMApp = (Get-ItemProperty -Path $teamsIMProvider -Name PreviousDefaultIMApp -ErrorAction SilentlyContinue).PreviousDefaultIMApp
        if ($previousDefaultIMApp) {
            New-ItemProperty -Path $imProviders -Name DefaultIMApp -Value $previousDefaultIMApp -PropertyType STRING -Force
        } else {
            Remove-ItemProperty -Path $imProviders -Name DefaultIMApp -ErrorAction SilentlyContinue
        }
    }
}

# Program close behaviour option
if($exitOnClose) {
    Write-Verbose '4 - Disabling the "runningOnClose" option...'
    $fileBuffer = $fileBuffer -replace '"runningOnClose":true', '"runningOnClose":false'
} else {
    Write-Verbose '4 - Enabling the "runningOnClose" option...'
    $fileBuffer = $fileBuffer -replace '"runningOnClose":false', '"runningOnClose":true'
}

# Output our modified data back into the configuration file, force overwriting the contents
Write-Verbose "Overwriting the contents of $configFile"
$fileBuffer | Set-Content $configFile -Force

# Stopping the log
Stop-Transcript

#endregion Execute
