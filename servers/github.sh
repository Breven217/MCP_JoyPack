#!/bin/bash
# Github MCP Server Setup Script

# Define the name used in the MCP config
CONFIG_NAME="github"
DOCUMENTATION_LINK="https://github.com/github/github-mcp-server"

# Function to create Github environment file
setup_github() {
    echo -e "\n${BLUE}Setting up Github MCP server...${NC}"

    # Pull Docker image
    # echo -e "\n${BLUE}Pulling Github MCP server Docker image...${NC}"
    # docker pull ghcr.io/breven217/joyfulsql_mcp:latest
    
    # Ensure MCP directory exists
    mkdir -p ~/.mcp
    
    # Check if environment file exists
    if [ -f ~/.mcp/github.env ]; then
        echo -e "${YELLOW}Github environment file already exists at ~/.mcp/github.env${NC}"
        echo -n "Would you like to update it? (y/n): "
        read -r update_env
        
        if [[ "$update_env" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            create_github_env
        fi
    else
        create_github_env
    fi
    
    # Update MCP config
    update_github_config
    
    echo -e "\n${GREEN}Github MCP server installation completed!${NC}"
    echo -e "${BLUE}You can now use the Github MCP server with Windsurf/Codeium.${NC}"
}

# Function to create Github environment file
create_github_env() {
    # Local
    echo -e "\n${BLUE}Setting up Github environment file...${NC}"

    printf "Enter your Github Personal Access Token (created "
    clickable_link "here" "https://github.com/settings/personal-access-tokens/new?target_name=BambooHR"
    printf "): "
    read -r github_token

    # Create environment file
    cat > ~/.mcp/github.env << EOF
GITHUB_PERSONAL_ACCESS_TOKEN=$github_token
EOF

    echo -e "${GREEN}Github environment file created successfully at ~/.mcp/github.env${NC}"
}

# Function to update MCP config for Github
update_github_config() {
    echo -e "\n${BLUE}Updating Windsurf MCP configuration for Github...${NC}"
    
    # Create the server configuration
    local server_config='{
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": ""
      }
    }'
    
    # Update the config using the common function
    update_mcp_config "github" "$server_config"
}