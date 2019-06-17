# Set-UserTeamsPreference

A PowerShell script to modify a users preferences in the Microsoft Teams Desktop Client.

*Thanks go out to James Rankin https://james-rankin.com/articles/microsoft-teams-on-citrix-xenapp/ for the code inspiration.*

## Usage

This script works by accepting commandline switches, defining a switch enforces the option, else sets it back to default.

- openAsHidden
-- Minimize Teams to Systray on autostart
- DisableAutoStart
-- Disables automatic launch of the Teams Client
- registerAsIMProvider
-- Registers the Teams Client as an Instant Message client
- exitOnClose
-- Exists the teams client on closing the window, instead of running it in the background


# Deploy with Intune
This script was made to be deployed as a win32app by Intune.
This is also the reason for commandline parameters.
So that you don't have to repackage the script each time you want to change preferences, or if you wish to have two sets of preferences for different groups of users - the same .intune package can be used.

You will need to set a dependecy rule that ensures that Teams is installed as the user before installation.
As this script will fail if the configuration file is not present in "%APPDATA%\Microsoft\Teams\desktop-config.json"

*You could also make a custom Teams installer script which runs the script after installation of the client.*

A transcript is saved to the users TEMP folder, for easier debugging than the Intune logs.
"%TEMP%\Set-UserTeamsPreference_Script-log.txt"



