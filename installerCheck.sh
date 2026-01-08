#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check and display version of a tool
check_version() {
    if command -v "$1" &>/dev/null; then
        echo -e "${GREEN}$1 is installed:${NC} $($1 --version | head -n 1)"
    else
        echo -e "${RED}$1 is not installed.${NC}"
    fi
}

# Header
echo -e "${GREEN}=== Development Tools Version Check ===${NC}"
echo

# Check each tool
check_version clang
check_version g++
check_version gcc
check_version make
check_version python3
check_version dotnet
check_version java
check_version rustc
check_version npm

check_version gitleaks

# Footer
echo -e "${GREEN}========================================${NC}"


# # Function to check and display version of a tool
# check_version() {
#     tool=$1

#     if command -v "$tool" &>/dev/null; then
#         # Try the common version flags first
#         version=$($tool --version 2>&1 || $tool -v 2>&1)

#         # If the version flag fails, try the version subcommand if applicable
#         if [[ $? -ne 0 ]]; then
#             # Special case for gitleaks, it uses 'version' subcommand
#             if [[ "$tool" == "gitleaks" ]]; then
#                 version=$($tool version 2>&1)
#             fi
#         fi

#         # If we successfully retrieved the version, display it
#         if [[ $? -eq 0 ]]; then
#             echo -e "${GREEN}$tool is installed:${NC} $version"
#         else
#             echo -e "${RED}$tool: Version check failed (flag and subcommand).${NC}"
#         fi
#     else
#         echo -e "${RED}$tool is not installed.${NC}"
#     fi
# }

