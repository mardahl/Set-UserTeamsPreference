#Requires -Version 5.0
<#
.SYNOPSIS
Set a users Teams Preference
.DESCRIPTION
This script will change the the users Teams configuration file, so the client behaves as requested by the administrator.
.EXAMPLE
Run the script as is, to set defaults
.EXAMPLE
Make teams start minimized to systray and register as an IM provider
Set-UserTeamsPreference.ps1 -openAsHidden -registerAsIMProvider
.NOTES
NAME: Set-UserTeamsPreference.ps1
VERSION: 1906a
PREREQ:  Make sure Teams is installed as the user before running!
Coded for readability!
.COPYRIGHT
@michael_mardahl / https://www.iphase.dk
Licensed under the MIT license.
Please credit me if you fint this script useful and do some cool things with it.
Thanks go out to James Rankin https://james-rankin.com/articles/microsoft-teams-on-citrix-xenapp/ for the code inspiration.
#>

# Parameters that are accepted by the script, none are required.
PARAM(
    [switch]$openAsHidden,
    [switch]$disableAutoStart,
    [switch]$registerAsIMProvider,
    [switch]$exitOnClose
)

# Logging any errors to the users temp folder
Start-Transcript -Path "$env:TEMP\Set-UserTeamsPreference_Script-log.txt"
Write-Output "Modifying the users Teams client..."

# Enabling verbose output for our log
$VerbosePreference = "Continue"

# The users Teams configuration file
$configFile = "$ENV:APPDATA\Microsoft\Teams\desktop-config.json"

# Load the file data into a variable
Write-Verbose "Fetching the contents of $configFile"
try {
    $fileBuffer = Get-Content $configFile -ErrorAction Stop
} 
catch {
    throw "Could not fetch the users Teams config file! Make sure Teams is installed!"
    Stop-Transcript
}

### Modifying the variable so Teams beahves as dictated by the specified commandline parameters (or lack thereof)

# Hidden option
if($openAsHidden) {
    Write-Output '1 - Enabling the "openAsHidden" option...'
    $fileBuffer = $fileBuffer -replace '"openAsHidden":false', '"openAsHidden":true'
} else { 
    Write-Output '1 - Disabling the "openAsHidden" option...'
    $fileBuffer = $fileBuffer -replace '"openAsHidden":true', '"openAsHidden":false'
}

# Autostart option
if($disableAutoStart) {
    Write-Output '2 - Disabling the "openAtLogin" option...'
    $fileBuffer = $fileBuffer -replace '"openAtLogin":true', '"openAtLogin":false'
} else { 
    Write-Output '2 - Enabling the "openAtLogin" option...'
    $fileBuffer = $fileBuffer -replace '"openAtLogin":false', '"openAtLogin":true'
}

# IM Provider option
if($registerAsIMProvider) {
    Write-Output '3 - Enabling the "registerAsIMProvider" option...'
    $fileBuffer = $fileBuffer -replace '"registerAsIMProvider":false', '"registerAsIMProvider":true'
} else {
    Write-Output '3 - Disabling the "registerAsIMProvider" option...'
    $fileBuffer = $fileBuffer -replace '"registerAsIMProvider":true', '"registerAsIMProvider":false'
}

# Program close behaviour option
if($exitOnClose) {
    Write-Output '4 - Disabling the "runningOnClose" option...'
    $fileBuffer = $fileBuffer -replace '"runningOnClose":true', '"runningOnClose":false'
} else {
    Write-Output '4 - Enabling the "runningOnClose" option...'
    $fileBuffer = $fileBuffer -replace '"runningOnClose":false', '"runningOnClose":true'
}

# Output our modified data back into the configuration file, force overwriting the contents
Write-Verbose "Overwriting the contents of $configFile"
$fileBuffer | Set-Content $configFile

# Stopping the log
Stop-Transcript