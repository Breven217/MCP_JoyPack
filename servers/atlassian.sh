#!/bin/bash
# Atlassian MCP Server Setup Script

# Define the name used in the MCP config
CONFIG_NAME="mcp-atlassian"
DOCUMENTATION_LINK="https://github.com/sooperset/mcp-atlassian"

# Function to create Atlassian environment file
setup_atlassian() {
    echo -e "\n${BLUE}Setting up Atlassian MCP server...${NC}"

    # Pull Docker image
    echo -e "\n${BLUE}Pulling Atlassian MCP server Docker image...${NC}"
    docker pull ghcr.io/sooperset/mcp-atlassian:latest
    
    # Ensure MCP directory exists
    mkdir -p ~/.mcp
    
    # Check if environment file exists
    if [ -f ~/.mcp/atlassian.env ]; then
        echo -e "${YELLOW}Atlassian environment file already exists at ~/.mcp/atlassian.env${NC}"
        echo -n "Would you like to update it? (y/n): "
        read -r update_env
        
        if [[ "$update_env" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            create_atlassian_env
        fi
    else
        create_atlassian_env
    fi
    
    # Update MCP config
    update_atlassian_config
    
    echo -e "\n${GREEN}Atlassian MCP server installation completed!${NC}"
    echo -e "${BLUE}You can now use the Atlassian MCP server with Windsurf/Codeium.${NC}"
}

# Function to create Atlassian environment file
create_atlassian_env() {
    echo -e "\n${BLUE}Setting up Atlassian environment file...${NC}"
    
    echo -e -n "Enter your Jira URL or leave blank for default (${YELLOW}https://bamboohr.atlassian.net${NC}): "
    read -r jira_url
    
    echo -n "Enter your Jira username (email): "
    read -r jira_username
    
    echo -n "Enter your Jira API token: "
    read -r jira_token
    
    echo -n "Enter your Jira projects filter (comma-separated project keys, optional): "
    read -r jira_projects_filter
    
    # Create environment file
    cat > ~/.mcp/atlassian.env << EOF
JIRA_URL=$jira_url
JIRA_USERNAME=$jira_username
JIRA_API_TOKEN=$jira_token
EOF

    # Add optional projects filter if provided
    if [ -n "$jira_projects_filter" ]; then
        echo "JIRA_PROJECTS_FILTER=$jira_projects_filter" >> ~/.mcp/atlassian.env
    fi
    
    echo -e "${GREEN}Atlassian environment file created successfully at ~/.mcp/atlassian.env${NC}"
}

# Function to update MCP config for Atlassian
update_atlassian_config() {
    echo -e "\n${BLUE}Updating Windsurf MCP configuration for Atlassian...${NC}"
    
    # Create the server configuration
    local server_config='{
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--env-file",
        "'"$HOME/.mcp/atlassian.env"'",
        "ghcr.io/sooperset/mcp-atlassian:latest"
      ]
    }'
    
    # Update the config using the common function
    update_mcp_config "$CONFIG_NAME" "$server_config"
}
