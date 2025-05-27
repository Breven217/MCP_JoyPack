#!/bin/bash
# MySql MCP Server Setup Script

# Define the name used in the MCP config
CONFIG_NAME="mysql"

# Function to create MySQL environment file
setup_mysql() {
    echo -e "\n${BLUE}Setting up MySQL MCP server...${NC}"
    
    # Ensure MCP directory exists
    mkdir -p ~/.mcp
    
    # Check if environment file exists
    if [ -f ~/.mcp/mysql.env ]; then
        echo -e "${YELLOW}MySQL environment file already exists at ~/.mcp/mysql.env${NC}"
        echo -n "Would you like to update it? (y/n): "
        read -r update_env
        
        if [[ "$update_env" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            create_mysql_env
        fi
    else
        create_mysql_env
    fi
    
    # Update MCP config
    update_mysql_config
    
    echo -e "\n${GREEN}MySQL MCP server installation completed!${NC}"
    echo -e "${BLUE}You can now use the MySQL MCP server with Windsurf/Codeium.${NC}"
}

# Function to create MySQL environment file
create_mysql_env() {
    # Local
    echo -e "\n${BLUE}Setting up MySQL environment file...${NC}"

    echo -n "Do you want the MySql MCP to have write access to databases? (y/n): "
    read -r write_access
    
    if [[ "$write_access" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        write_access="true"
    else
        write_access="false"
    fi

    echo -e "\n${BLUE}Local MySQL Configuration${NC}"
    
    echo -e -n "Enter your Local Host or leave blank for default (${YELLOW}app.bamboolocal.com${NC}): "
    read -r local_host
    # Default host if not specified
    if [ -z "$local_host" ]; then
        local_host="app.bamboolocal.com"
    fi
    
    echo -e -n "Enter your Local User or leave blank for default (${YELLOW}web${NC}): "
    read -r local_user
    # Default user if not specified
    if [ -z "$local_user" ]; then
        local_user="web"
    fi
    
    echo -e -n "Enter your Local Password or leave blank for default (${YELLOW}password${NC}): "
    read -r local_password
    # Default password if not specified
    if [ -z "$local_password" ]; then
        local_password="password"
    fi
    
    echo -e -n "Enter your Local Port or leave blank for default (${YELLOW}3396${NC}): "
    read -r local_port
    # Default port if not specified
    if [ -z "$local_port" ]; then
        local_port=3396
    fi

    # Odi
    echo -e "\n${BLUE}Odi MySQL Configuration${NC}"
    
    echo -e -n "Enter your Odi Host or leave blank for default (${YELLOW}127.0.0.1${NC}): "
    read -r odi_host
    # Default host if not specified
    if [ -z "$odi_host" ]; then
        odi_host="127.0.0.1"
    fi
    
    echo -e -n "Enter your Odi User or leave blank for default (${YELLOW}web${NC}): "
    read -r odi_user
    # Default user if not specified
    if [ -z "$odi_user" ]; then
        odi_user="web"
    fi

    echo -e -n "Enter your Odi Port or leave blank for default (${YELLOW}3306${NC}): "
    read -r odi_port
    # Default port if not specified
    if [ -z "$odi_port" ]; then
        odi_port=3306
    fi

    echo -e -n "Enter your Odi SSH Port or leave blank for default (${YELLOW}22${NC}): "
    read -r odi_ssh_port
    # Default port if not specified
    if [ -z "$odi_ssh_port" ]; then
        odi_ssh_port=22
    fi

    echo -e -n "Enter your Odi SSH Key Path or leave blank for default (${YELLOW}$HOME/.ssh/id_rsa${NC}): "
    read -r odi_ssh_key
    # Odi SSH Key
    if [ -z "$odi_ssh_key" ]; then
        odi_ssh_key="$HOME/.ssh/id_rsa"
    fi

    # Use printf to create a clickable link in terminal
    printf "Enter your Odi Password (default can be found "
    printf "${BLUE}\e]8;;https://vault.bamboohr.io/ui/vault/secrets/shared/show/shared-product-dev/stage_database_password\e\\here\e]8;;${NC}\e\\"
    printf "): "
    
    read -r odi_password

    # Create environment file
    cat > ~/.mcp/mysql.env << EOF
LOCAL_HOST=$local_host
LOCAL_USER=$local_user
LOCAL_PASSWORD=$local_password
LOCAL_PORT=$local_port
ODI_HOST=$odi_host
ODI_USER=$odi_user
ODI_PASSWORD=$odi_password
ODI_PORT=$odi_port
ODI_SSH_PORT=$odi_ssh_port
ODI_SSH_KEY=$odi_ssh_key
WRITE_ACCESS=$write_access
EOF

    echo -e "${GREEN}MySQL environment file created successfully at ~/.mcp/mysql.env${NC}"
}

# Function to update MCP config for MySQL
update_mysql_config() {
    echo -e "\n${BLUE}Updating Windsurf MCP configuration for MySQL...${NC}"
    
    # Create the server configuration
    local server_config='{
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "--env-file",
        "'"$HOME/.mcp/mysql.env"'",
        "ghcr.io/breven217/joyfulsql_mcp:latest"
      ]
    }'
    
    # Update the config using the common function
    update_mcp_config "$CONFIG_NAME" "$server_config"
}
