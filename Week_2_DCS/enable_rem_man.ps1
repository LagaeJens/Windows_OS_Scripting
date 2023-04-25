#
# Enabling Remote Management (on the core server)
#

# QWERTY
#Set-WinUserLanguageList -LanguageList en-US -Force
# AZERTY
#Set-WinUserLanguageList -LanguageList nl-BE -Force

Enable-PSRemoting -Force
Enable-NetFirewallRule -DisplayName "*Network Access*"
Enable-NetFirewallRule -DisplayGroup "*Remote Event Log*"
Enable-NetFirewallRule -DisplayGroup "*Remote File Server Resource Manager Management*"
