-- MCP JoyPack Installer AppleScript
-- This script opens Terminal and runs the MCP JoyPack installation command

tell application "Terminal"
    activate
    do script "bash -c \"$(curl -fsSL https://bit.ly/MCPJoyPack)\""
end tell
