#!/bin/bash
# Rollbar MCP Server Setup Script

# Define the name used in the MCP config
CONFIG_NAME="rollbar"
DOCUMENTATION_LINK="https://github.com/rollbar/rollbar-mcp-server"

# Function to create Rollbar environment file
setup_rollbar() {
    echo -e "\n${BLUE}Setting up Rollbar MCP server...${NC}"

    # Ensure MCP directory exists
    mkdir -p ~/.mcp/repos

    # Clone the Rollbar repository into ~/.mcp/repos/rollbar-mcp-server
    echo -e "\n${BLUE}Cloning Rollbar repository...${NC}"
    cd ~/.mcp/repos
    git clone https://github.com/rollbar/rollbar-mcp-server.git
    cd rollbar-mcp-server

    # Install and build with npm
    echo -e "\n${BLUE}Installing and building Rollbar MCP server...${NC}"
    npm install
    npm run build
    
    # Check if environment file exists
    if [ -f ~/.mcp/rollbar.env ]; then
        echo -e "${YELLOW}Rollbar environment file already exists at ~/.mcp/rollbar.env${NC}"
        echo -n "Would you like to update it? (y/n): "
        read -r update_env
        
        if [[ "$update_env" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            create_rollbar_env
        fi
    else
        create_rollbar_env
    fi

    # Create wrapper to load env variables and run the server
    cat > ~/.mcp/repos/rollbar-mcp-server/rollbar-wrapper.sh << 'EOF'
#!/bin/bash
export $(cat /Users/bjoyner/.mcp/rollbar.env | xargs)
node ~/.mcp/repos/rollbar-mcp-server/build/index.js
EOF

    # Make the wrapper executable
    chmod +x ~/.mcp/repos/rollbar-mcp-server/rollbar-wrapper.sh

    # Update MCP config
    update_rollbar_config
    
    echo -e "\n${GREEN}Rollbar MCP server installation completed!${NC}"
    echo -e "${BLUE}You can now use the Rollbar MCP server with Windsurf/Codeium.${NC}"
}

# Function to create Rollbar environment file
create_rollbar_env() {
    # Local
    echo -e "\n${BLUE}Setting up Rollbar environment file...${NC}"

    echo -n "Enter your Rollbar access token (web app token can be found "
    clickable_link "here" "https://vault.bamboohr.io/ui/vault/secrets/shared/show/shared-product-dev/Rollbar-read-token-BambooHR-web-app-project"
    echo -n "): "
    read -r access_token

    # Create environment file
    cat > ~/.mcp/rollbar.env << EOF
export ACCESS_TOKEN=$access_token
EOF

    echo -e "\n${GREEN}Rollbar environment file created successfully at ~/.mcp/rollbar.env${NC}"
}

# Function to update MCP config for Rollbar
update_rollbar_config() {
    echo -e "\n${BLUE}Updating Windsurf MCP configuration for Rollbar...${NC}"
    
    # Create the server configuration
    local server_config='{
      "command": "'"$HOME/.mcp/repos/rollbar-mcp-server/rollbar-wrapper.sh"'",
      "args": [],
      "env": {}
    }'
    
    # Update the config using the common function
    update_mcp_config "$CONFIG_NAME" "$server_config"
}
