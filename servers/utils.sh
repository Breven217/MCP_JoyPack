#!/bin/bash

# Utility functions for MCP server setup scripts

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to update MCP config for a specific server
update_mcp_config() {
    local server_name="$1"
    local server_config="$2"
    
    # Ensure config directory exists
    mkdir -p ~/.codeium/windsurf
    
    # Check if MCP config exists
    if [ -f ~/.codeium/windsurf/mcp_config.json ]; then
        echo "Existing MCP config found."
        
        # Check if the server already exists in the config using the is_server_installed function
        if is_server_installed "$server_name"; then
            echo -e "${YELLOW}Server '$server_name' already exists in the MCP config.${NC}"
            echo -n "Would you like to update it? (y/n): "
            read -r update_config
            
            if [[ ! "$update_config" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                echo -e "${BLUE}Skipping update for $server_name.${NC}"
                return 0
            fi
        fi
        
        # Backup existing config
        cp ~/.codeium/windsurf/mcp_config.json ~/.codeium/windsurf/mcp_config.json.backup
        
        # Check if jq is installed for JSON manipulation
        if command -v jq &> /dev/null; then
            # Use jq to update config
            jq ".mcpServers.\"$server_name\" = $server_config" ~/.codeium/windsurf/mcp_config.json.backup > ~/.codeium/windsurf/mcp_config.json
            echo -e "${GREEN}MCP config updated successfully using jq.${NC}"
        else
            echo -e "${YELLOW}jq is not installed. Will attempt manual update.${NC}"
            echo -e "${YELLOW}For best results, please install jq:${NC}"
            echo -e "  - Mac: brew install jq"
            echo -e "  - Linux: apt-get install jq or yum install jq"
            
            # Check if server already exists in config
            if grep -q "\"$server_name\"" ~/.codeium/windsurf/mcp_config.json; then
                echo -e "${YELLOW}Warning: Cannot update existing config without jq. Please install jq or manually update the config.${NC}"
                echo "Required configuration for $server_name:"
                echo "$server_config"
            else
                # Try to add to config if not exists
                # This is a simple approach and might not work for all JSON structures
                sed -i.bak "/\"mcpServers\"[[:space:]]*:[[:space:]]*{/ a\\
  \"$server_name\": $server_config," ~/.codeium/windsurf/mcp_config.json
                echo -e "${YELLOW}Attempted to update MCP config manually. Please verify the file is valid.${NC}"
            fi
        fi
    else
        # Create new config file
        cat > ~/.codeium/windsurf/mcp_config.json << EOF
{
  "mcpServers": {
    "$server_name": $server_config
  }
}
EOF
        echo -e "${GREEN}New MCP config created successfully.${NC}"
    fi
}

# Function to check Docker installation
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
        echo "Visit https://docs.docker.com/get-docker/ for installation instructions."
        return 1
    fi
    return 0
}

# Function to check if a server is installed
is_server_installed() {
    local server_name="$1"
    local config_name
    
    # Get the CONFIG_NAME variable from the server script if available
    if [ -f "$SCRIPT_DIR/servers/$server_name.sh" ]; then
        # Source the script to get the CONFIG_NAME variable
        # We use a subshell to avoid polluting the current environment
        config_name=$(bash -c "source $SCRIPT_DIR/servers/$server_name.sh 2>/dev/null && echo \$CONFIG_NAME")
    fi
    
    # If CONFIG_NAME wasn't defined, use a fallback approach
    if [ -z "$config_name" ]; then
        # Fallback: try common naming patterns
        config_name="$server_name"
    fi
    
    # Check if MCP config exists
    if [ -f ~/.codeium/windsurf/mcp_config.json ]; then
        # Use jq if available for more reliable JSON parsing
        if command -v jq &> /dev/null; then
            # Check if the mcpServers object exists and contains the server
            if jq -e ".mcpServers | has(\"$config_name\")" ~/.codeium/windsurf/mcp_config.json &> /dev/null; then
                return 0  # Server is installed
            fi
        else
            # Fallback to grep if jq is not available
            if grep -q "\"$config_name\"" ~/.codeium/windsurf/mcp_config.json; then
                return 0  # Server is installed
            fi
        fi
    fi
    
    return 1  # Server is not installed
}

# Function to list available servers
list_available_servers() {
    local servers_dir="$1"
    local i=1
    
    echo -e "\n${BLUE}Available MCP servers:${NC}"
    echo -e "${BLUE}----------------------${NC}"
    
    # List all .sh files except utils.sh
    for server_file in "$servers_dir"/*.sh; do
        # Skip utils.sh
        if [[ "$(basename "$server_file")" != "utils.sh" ]]; then
            server_name=$(basename "$server_file" .sh)
            
            # Check if server is installed
            if is_server_installed "$server_name"; then
                echo -e "$i. $server_name ${GREEN}[Installed]${NC}"
            else
                echo "$i. $server_name"
            fi
            
            i=$((i+1))
        fi
    done
    
    echo "0. install all"
    echo "x. exit"
    echo ""
}
