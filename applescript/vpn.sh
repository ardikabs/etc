#!/bin/bash

set -eo pipefail

vpn_names=(
    "VPN Development"
    "VPN Staging"
    "VPN Production"
)
choice=$(printf "%s\n" "${vpn_names[@]}" | fzf)
token=$(/usr/local/bin/totp)
vpn_name="${choice}, Not Connected"
/usr/bin/osascript <<EOF 2>&1 |grep -v GetInputSourceEnabledPrefs
tell application "System Preferences"
       reveal pane "Network"
       activate
end tell

tell application "System Events"
    tell process "System Preferences"
        tell window 1
            repeat while not (rows of table 1 of scroll area 1 exists)
            end repeat

            repeat with current_row in (rows of table 1 of scroll area 1)
                if value of static text 1 of current_row is equal to "$vpn_name" then
                    select current_row
                    exit repeat
                else
                    tell application "System Preferences" to quit
                    return "$choice is already connected"
                end if
            end repeat

            repeat with current_button in (buttons in group 1)
                if name of current_button is equal to "Authentication Settings..." then
                    click current_button
                    exit repeat
                end if
            end repeat

            tell sheet 1
                set focused of text field 2 to true
                set value of text field 2 to "$token"
                click button "Ok"
            end tell
            click button "Apply"

            delay 1
            repeat with current_button in (buttons in group 1)
                if name of current_button is equal to "Connect" then
                    click current_button
                    exit repeat
                end if
            end repeat
        end tell
    end tell
end tell

tell application "System Preferences" to quit
EOF