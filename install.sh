#!/bin/bash

# MCP JoyPack - Modular MCP Server Installer
# This script provides a one-liner way to install various MCP servers

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the utility functions
source "$SCRIPT_DIR/servers/utils.sh"

echo ""
echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}MCP JoyPack - MCP Server Installer${NC}"
echo -e "${BLUE}=======================================${NC}"

# Function to handle one-liner installation
handle_one_liner_install() {
    # If this script was run directly (not sourced), and we're in a one-liner context
    # We need to download the entire repository to a temporary directory
    if [ "$0" = "bash" ] || [ "$(basename "$0")" = "bash" ]; then
        echo -e "${BLUE}Running in one-liner mode. Downloading MCP JoyPack...${NC}"
        
        # Create a temporary directory
        TMP_DIR=$(mktemp -d)
        echo -e "${BLUE}Created temporary directory: $TMP_DIR${NC}"
        
        # Clone the repository to the temporary directory
        echo -e "${BLUE}Cloning repository...${NC}"
        git clone https://github.com/Breven217/MCP_JoyPack.git "$TMP_DIR" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}Git clone failed. Trying direct download...${NC}"
            curl -L https://github.com/Breven217/MCP_JoyPack/archive/main.tar.gz | tar xz -C "$TMP_DIR" --strip-components=1
        fi
        
        # Make sure scripts are executable
        chmod +x "$TMP_DIR/install.sh"
        chmod +x "$TMP_DIR/servers"/*.sh 2>/dev/null
        
        # Run the local installation from the temporary directory
        echo -e "${BLUE}Running installation from $TMP_DIR...${NC}"
        cd "$TMP_DIR"
        # Use the full path to ensure SCRIPT_DIR is set correctly
        bash "$TMP_DIR/install.sh" --local
        
        # Clean up
        echo -e "${BLUE}Cleaning up temporary files...${NC}"
        cd - > /dev/null
        rm -rf "$TMP_DIR"
        exit 0
    fi
}

# Try to handle one-liner installation if applicable
handle_one_liner_install

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
    # Check for local flag (used in one-liner installation)
    if [[ "$1" == "--local" ]]; then
        echo -e "${BLUE}Running in local mode from downloaded repository${NC}"
        # Make sure SCRIPT_DIR is correctly set
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        echo -e "${BLUE}Script directory: $SCRIPT_DIR${NC}"
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
    
    while true; do
        # List available servers
        list_available_servers "$SCRIPT_DIR/servers"
        
        echo -n "Select an MCP server to install (or update): "
        read -r choice
        
        if [[ "$choice" == "x" ]]; then
            echo -e "${GREEN}Exiting MCP JoyPack. Goodbye!${NC}"
            echo ""
            exit 0
        elif [[ "$choice" == "0" ]]; then
            # Install all servers
            install_all_servers
        elif [[ "$choice" =~ ^[0-9]+$ ]]; then
            # Get all server scripts (excluding utils.sh)
            local server_files=($(find "$SCRIPT_DIR/servers" -name "*.sh" ! -name "utils.sh" | sort))
            local server_count=${#server_files[@]}
            
            if [ "$choice" -le "$server_count" ] && [ "$choice" -gt 0 ]; then
                # Get the selected server name (array is 0-indexed, so subtract 1 from choice)
                local index=$((choice-1))
                local selected_server=$(basename "${server_files[$index]}" .sh)
                
                # Run the setup for the selected server
                run_server_setup "$selected_server"
            else
                echo -e "${YELLOW}Invalid option. Please try again.${NC}"
            fi
        else
            echo -e "${YELLOW}Invalid option. Please try again.${NC}"
        fi
    done
}

# Start the main function
main

