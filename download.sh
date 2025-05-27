#!/bin/bash

# MCP JoyPack Downloader
# This script downloads the MCP JoyPack repository and runs the installer

# Colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}MCP JoyPack - Downloader${NC}"
echo -e "${BLUE}=======================================${NC}"

# Create a temporary directory
TMP_DIR=$(mktemp -d)
echo -e "${BLUE}Created temporary directory: $TMP_DIR${NC}"

# Download the repository directly
echo -e "${BLUE}Downloading MCP JoyPack...${NC}"
curl -L https://github.com/Breven217/MCP_JoyPack/archive/main.tar.gz | tar xz -C "$TMP_DIR" --strip-components=1

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to download MCP JoyPack. Please check your internet connection and try again.${NC}"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Make scripts executable
echo -e "${BLUE}Making scripts executable...${NC}"
chmod +x "$TMP_DIR/install.sh"
find "$TMP_DIR/servers" -name "*.sh" -exec chmod +x {} \;

# Run the installer
echo -e "${BLUE}Running MCP JoyPack installer...${NC}"
cd "$TMP_DIR"
bash ./install.sh

# Clean up
echo -e "${BLUE}Cleaning up...${NC}"
cd - > /dev/null
rm -rf "$TMP_DIR"

echo -e "${GREEN}MCP JoyPack installation complete!${NC}"
