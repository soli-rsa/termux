#!/data/data/com/termux/files/usr/bin/bash
set -e

#
# build.sh - Neovim Development Environment Metapackage Creator for Termux
#
# This script creates a Termux metapackage that installs a comprehensive
# Neovim development environment. It includes dependency verification,
# architecture detection, version validation, and other features to ensure
# a robust and user-friendly installation.
#
# Security Considerations:
# - This script uses 'dpkg -i' to install the created package, which requires trust.
# - It's recommended to review the script and the packages it installs.
# - For enhanced security, consider adding SHA256 checksum verification for
#   downloaded components in a production environment.
#

# --- Configuration ---

# Set colors for user-friendly output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Package details
MAINTAINER="Jules"
HOMEPAGE="https://github.com/your-repo/nvim-dev-env" # TODO: Update with actual repo URL
PACKAGE_NAME="nvim-dev-env"
VERSION="1.0.0"
DESCRIPTION="A metapackage for setting up a Neovim development environment in Termux."

# Customizable list of packages for the Neovim environment
# Users can override this by setting the NVIM_DEV_PACKAGES environment variable
: "${NVIM_DEV_PACKAGES:="neovim python-pynvim lazygit ripgrep fd eza bat curl luarocks stylua lua-language-server nodejs deno esbuild shellcheck shfmt"}"


# --- Helper Functions ---

# Helper function for showing progress dots during long operations
show_progress() {
    local pid=$1
    local message=$2
    echo -n -e "${YELLOW}$message${NC}"
    while kill -0 "$pid" 2>/dev/null; do
        echo -n "."
        sleep 1
    done
    echo -e " ${GREEN}done!${NC}"
}

# --- Pre-build Checks ---

# Function for architecture and version validation
check_environment() {
    # Add architecture detection
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|armv7l|armv8l|x86_64|i686)
            echo -e "${GREEN}✓ Supported architecture: $ARCH${NC}"
            ;;
        *)
            echo -e "${RED}✗ Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac

    # Validate Termux version
    TERMUX_VERSION=$(pkg show termux-tools | grep Version | awk '{print $2}' | cut -d'-' -f1)
    if [ -z "$TERMUX_VERSION" ]; then
        echo -e "${YELLOW}Warning: Could not detect Termux version.${NC}"
    else
        echo -e "${GREEN}✓ Termux version: $TERMUX_VERSION${NC}"
    fi
}

# Function to verify that all packages are available in Termux repositories
verify_dependencies() {
    echo -e "${GREEN}Verifying all packages are available in Termux repositories...${NC}"
    MISSING_PACKAGES=()
    for pkg in $NVIM_DEV_PACKAGES; do
        if ! pkg show "$pkg" &>/dev/null; then
            MISSING_PACKAGES+=("$pkg")
        fi
    done

    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        echo -e "${RED}The following packages are not available in Termux repositories:${NC}"
        printf " - %s\n" "${MISSING_PACKAGES[@]}"
        echo -e "${YELLOW}Please check package names and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ All required packages are available.${NC}"
}

# Function to back up existing Neovim configurations
backup_existing_config() {
    if [ -d "$HOME/.config/nvim" ]; then
        local backup_dir="$HOME/.config/nvim_backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing Neovim configuration to $backup_dir${NC}"
        cp -r "$HOME/.config/nvim" "$backup_dir"
        echo -e "${GREEN}✓ Backup created: $backup_dir${NC}"
    fi
}


# --- Build Steps ---

# Function to create the uninstall script
create_uninstall_script() {
    echo -e "${GREEN}Creating uninstall script...${NC}"
    mkdir -p data/share/doc/$PACKAGE_NAME
    cat > data/share/doc/$PACKAGE_NAME/uninstall.sh << EOF
#!/data/data/com/termux/files/usr/bin/bash
echo "Uninstalling nvim-dev-env metapackage..."
echo "Note: This only removes the metapackage, not the individual packages."
echo "To remove individual packages, run:"
echo "pkg remove $NVIM_DEV_PACKAGES"
EOF
    chmod +x data/share/doc/$PACKAGE_NAME/uninstall.sh
    echo -e "${GREEN}✓ Uninstall script created.${NC}"
}

# Function to create the manifest.json file
create_manifest() {
    echo -e "${GREEN}Creating manifest.json...${NC}"
    # Create a temporary file for dependencies
    deps_json=$(mktemp)
    echo -n ' "depends": [' > "$deps_json"
    first=true
    for pkg in $NVIM_DEV_PACKAGES; do
        if [ "$first" = true ]; then
            first=false
        else
            echo -n ',' >> "$deps_json"
        fi
        echo -n "\"$pkg\"" >> "$deps_json"
    done
    echo ']' >> "$deps_json"

    # Create the manifest.json file
    cat > manifest.json << EOF
{
    "name": "$PACKAGE_NAME",
    "version": "$VERSION",
    "maintainer": "$MAINTAINER",
    "homepage": "$HOMEPAGE",
    "architecture": "all",
    "description": "$DESCRIPTION",
    $(cat "$deps_json"),
    "files": {
        "data/share/doc/$PACKAGE_NAME/uninstall.sh": "share/doc/$PACKAGE_NAME/uninstall.sh"
    }
}
EOF
    rm "$deps_json"
    echo -e "${GREEN}✓ manifest.json created.${NC}"
}

# Function to build the package
build_package() {
    local deb_file="${PACKAGE_NAME}_${VERSION}_all.deb"
    (termux-create-package manifest.json) & pid=$!
    show_progress $pid "Building package"
    # Move the created package to the original directory
    mv "$deb_file" "$OLDPWD"
    echo -e "${GREEN}✓ Package built: $OLDPWD/$deb_file${NC}"
}

# Function to verify package integrity
verify_package() {
    local deb_file="$OLDPWD/${PACKAGE_NAME}_${VERSION}_all.deb"
    echo -e "${GREEN}Verifying package integrity...${NC}"

    if ! dpkg -I "$deb_file" &>/dev/null; then
        echo -e "${RED}✗ Package verification failed (dpkg -I)${NC}"
        return 1
    fi

    local pkg_size
    pkg_size=$(stat -c%s "$deb_file")
    if [ "$pkg_size" -lt 1024 ]; then
        echo -e "${RED}✗ Package size seems too small${NC}"
        return 1
    fi

    echo -e "${GREEN}✓ Package verification passed${NC}"
    return 0
}

# --- Post-build Actions ---

# Function to prompt the user for package installation
install_package_prompt() {
    local deb_file="$OLDPWD/${PACKAGE_NAME}_${VERSION}_all.deb"
    echo -e "${YELLOW}Would you like to install the metapackage now? (y/n)${NC}"
    read -r -p "Response: " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${GREEN}Installing metapackage...${NC}"
        if dpkg -i "$deb_file"; then
            echo -e "${GREEN}✓ Metapackage installed successfully!${NC}"
            echo -e "${YELLOW}Please restart your Termux session for all changes to take effect.${NC}"
        else
            echo -e "${RED}✗ Installation failed. Please install the package manually with 'dpkg -i $deb_file'.${NC}"
        fi
    else
        echo -e "${YELLOW}You can install the package later by running: dpkg -i $deb_file${NC}"
    fi
}


# --- Main Build Process ---
# Function to check for required build tools
check_build_tools() {
    echo -e "${GREEN}Checking for required build tools...${NC}"
    if ! command -v termux-create-package &> /dev/null; then
        echo -e "${RED}✗ termux-create-package is not installed. Please install it with 'pkg install termux-tools'.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Build tools are present.${NC}"
}


# --- Main Build Process ---

main() {
    echo -e "${GREEN}Starting the Neovim metapackage creation process...${NC}"

    # Perform pre-build checks
    check_environment
    check_build_tools
    verify_dependencies

    # Back up existing Neovim configuration
    backup_existing_config

    # Create temporary build directory
    local build_dir
    build_dir=$(mktemp -d)
    echo -e "${GREEN}Created temporary build directory at: $build_dir${NC}"
    cd "$build_dir"

    # Generate package components
    create_uninstall_script
    create_manifest

    # Build the package
    build_package

    # Verify the created package
    if ! verify_package; then
        exit 1
    fi

    # Prompt for installation
    install_package_prompt

    # Cleanup
    echo -e "${GREEN}Cleaning up temporary files...${NC}"
    rm -rf "$build_dir"

    echo -e "${GREEN}✓ Metapackage created successfully!${NC}"
}

# Run the main function
main "$@"
