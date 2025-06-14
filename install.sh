#!/bin/bash

# MCP JoyPack - Modular MCP Server Installer
# This script provides an easy way to install various MCP servers

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}MCP JoyPack - MCP Server Installer${NC}"
echo -e "${BLUE}=======================================${NC}"

# Source the utility functions
source "$SCRIPT_DIR/servers/utils.sh"

# Function to load server scripts
load_server_scripts() {
    # Source all server scripts
    for server_file in "$SCRIPT_DIR/servers"/*.sh; do
        # Skip utils.sh as it's already sourced
        if [[ "$(basename "$server_file")" != "utils.sh" ]]; then
            source "$server_file"
        fi
    done
}

# Function to run the selected server setup
run_server_setup() {
    local server_name="$1"
    
    # Convert server name to function name (e.g., atlassian -> setup_atlassian)
    local setup_function="setup_$server_name"
    
    # Check if the function exists
    if declare -f "$setup_function" > /dev/null; then
        # Call the setup function
        "$setup_function"
    else
        echo -e "${YELLOW}Setup function for $server_name not found.${NC}"
    fi
}

# Function to install all servers
install_all_servers() {
    echo -e "\n${GREEN}Installing all available MCP servers...${NC}"
    
    # Get all server scripts (excluding utils.sh) as an array
    local server_files=($(find "$SCRIPT_DIR/servers" -name "*.sh" ! -name "utils.sh" | sort))
    local total_servers=${#server_files[@]}
    
    echo -e "${BLUE}Found $total_servers MCP servers to install.${NC}"
    
    # Install each server
    for ((i=0; i<$total_servers; i++)); do
        local server_file="${server_files[$i]}"
        local server_name=$(basename "$server_file" .sh)
        local current=$((i+1))
        
        echo -e "\n${BLUE}[$current/$total_servers] Installing $server_name MCP server...${NC}"
        
        # Run the setup for this server
        run_server_setup "$server_name"
    done
    
    echo -e "\n${GREEN}All MCP servers have been installed!${NC}"
}

# Main function
main() {
    # Flag to track if we're running in one-liner mode
    local one_liner_mode=false
    
    # Check for local flag (used in one-liner installation)
    if [[ "$1" == "--local" ]]; then
        echo -e "${BLUE}Running in local mode from downloaded repository${NC}"
        # Make sure SCRIPT_DIR is correctly set
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        echo -e "${BLUE}Script directory: $SCRIPT_DIR${NC}"
        one_liner_mode=true
    fi
    
    # Check if servers directory exists
    if [ ! -d "$SCRIPT_DIR/servers" ]; then
        echo -e "${RED}Error: servers directory not found at $SCRIPT_DIR/servers${NC}"
        echo -e "${YELLOW}This may be due to an incomplete download or incorrect directory structure.${NC}"
        exit 1
    fi
    
    # Check if utils.sh exists
    if [ ! -f "$SCRIPT_DIR/servers/utils.sh" ]; then
        echo -e "${RED}Error: utils.sh not found at $SCRIPT_DIR/servers/utils.sh${NC}"
        echo -e "${YELLOW}This may be due to an incomplete download or incorrect directory structure.${NC}"
        exit 1
    fi
    
    # Source the utility functions again to be safe
    source "$SCRIPT_DIR/servers/utils.sh"
    
    # Load all server scripts
    load_server_scripts
    
    # Get available server scripts
    local server_files=($(find "$SCRIPT_DIR/servers" -name "*.sh" ! -name "utils.sh" 2>/dev/null | sort))
    local server_count=${#server_files[@]}
    
    # Check if we found any server scripts
    if [ $server_count -eq 0 ]; then
        echo -e "${RED}Error: No server scripts found in $SCRIPT_DIR/servers${NC}"
        echo -e "${YELLOW}This may be due to an incomplete download or incorrect directory structure.${NC}"
        echo -e "Directory contents:"
        ls -la "$SCRIPT_DIR/servers"
        exit 1
    fi
    
    echo -e "${GREEN}Found $server_count MCP servers available for installation.${NC}"
    
    while true; do
        # List available servers
        list_available_servers "$SCRIPT_DIR/servers"
        
        echo -n "Select an MCP server to install (or update): "
        read -r choice
        
        if [[ "$choice" == "x" ]]; then
            echo -e "${GREEN}Exiting MCP JoyPack. Goodbye!${NC}"
            exit 0
        elif [[ "$choice" == "0" ]]; then
            # Install all servers
            install_all_servers
        elif [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -le "$server_count" ] && [ "$choice" -gt 0 ]; then
                # Get the selected server name (array is 0-indexed, so subtract 1 from choice)
                local index=$((choice-1))
                local selected_server=$(basename "${server_files[$index]}" .sh)
                
                echo -e "${BLUE}Selected server: $selected_server${NC}"
                
                # Run the setup for the selected server
                run_server_setup "$selected_server"
            else
                echo -e "${YELLOW}Invalid option. Please select a number between 1 and $server_count, or 0 for all servers.${NC}"
            fi
        else
            echo -e "${YELLOW}Invalid option. Please select a number between 1 and $server_count, 0 for all servers, or x to exit.${NC}"
        fi
    done
}

# Start the main function
main

