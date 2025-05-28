# MCP JoyPack

A modular, extensible system to easily install and configure MCP (Model Context Protocol) servers for Windsurf/Codeium.

## Overview

MCP JoyPack provides the easiest way to set up various MCP servers. It features a modular design that makes it simple to add support for new MCP servers.

#### Current MCP Servers

- Atlassian
- MySQL
- Rollbar
- Github

## Prerequisites

- Docker (https://docs.docker.com/get-docker/)

## Installation

<i>📋 Copy the command below and paste it in your terminal</i>

```
bash -c "$(curl -fsSL https://bit.ly/MCPJoyPack)"
```

That's it! The script will:
1. Download the MCP JoyPack to a temporary directory
2. Run the interactive installer
3. Guide you through selecting and configuring your desired MCP servers
4. Clean up automatically when finished

No need to clone the repository or install any additional tools (other than Docker).

## Modular Architecture

MCP JoyPack uses a modular architecture where:

1. Each MCP server has its own script in the `servers/` directory
2. A master installation script dynamically discovers and loads these server-specific scripts
3. Common utility functions are shared across all server scripts

This makes it easy to add support for new MCP servers without modifying the core installation logic.

## Available MCP Servers

### Atlassian MCP Server

The Atlassian MCP server provides access to Jira functionality through the MCP protocol.

#### Configuration

You'll need to provide:
- Jira URL
- Jira username (your email)
- Jira API token (https://id.atlassian.com/manage-profile/security/api-tokens)
- Jira projects filter (optional, comma-separated project keys)

### Joyful SQL MCP Server

The Joyful SQL MCP server provides access to Local and ODI MySQL functionality through the MCP protocol.

#### Configuration

You'll need to provide:
- Local Host
- Local User
- Local Password
- Local Port
- Odi Host
- Odi User
- Odi Password
- Odi Port
- Odi SSH Port
- Odi SSH Key Path

### Rollbar MCP Server

The Rollbar MCP server provides access to Rollbar functionality through the MCP protocol.

#### Configuration

You'll need to provide:
- Rollbar API Token

### Github MCP Server

The Github MCP server provides access to Github functionality through the MCP protocol.

#### Configuration

You'll need to provide:
- Github API Token (https://github.com/settings/personal-access-tokens/new?target_name=BambooHR)

## Windsurf/Codeium Integration

MCP JoyPack automatically configures your MCP servers for use with Windsurf/Codeium by:

1. Creating the necessary environment files in `~/.mcp/` directory
2. Updating the Windsurf MCP configuration at `~/.codeium/windsurf/mcp_config.json`

## Adding More MCP Servers

Adding a new MCP server is simple with the modular architecture:

1. Create a new script in the `servers/` directory (e.g., `servers/new-server.sh`)
2. Define a `setup_[server-name]()` function that handles the server-specific setup
3. That's it! The main script will automatically detect and include it

### Example Template for a New Server

```bash
#!/bin/bash

# New Server MCP Setup Script
# Define the name used in the MCP config
CONFIG_NAME="mcp-new-server"

# Documentation link for the new server this will be used as a clickable link in the installer
DOCUMENTATION_LINK="https://github.com/your-repo/new-server-mcp"

# Function to set up the new server
setup_new-server() {
    echo -e "\n${BLUE}Setting up New Server MCP server...${NC}"
    
    # Your server-specific setup code here
    # ...
    
    # Update MCP config
    local server_config='{"command": "docker", "args": [...]}'  # Your server config
    update_mcp_config "filename" "$server_config"
    
    echo -e "\n${GREEN}New Server MCP server installation completed!${NC}"
}
```

## Troubleshooting Tips

- You got this!
