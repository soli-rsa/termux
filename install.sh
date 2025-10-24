#!/data/data/com.termux/files/usr/bin/bash
#
# install.sh - One-line installer for the Neovim Development Environment Metapackage
#
# This script downloads and runs the build script for the nvim-dev-env metapackage.
#
# To use, run:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/your-repo/nvim-dev-env/main/install.sh)"
#
# Security Considerations:
# - This script downloads and executes another script from the internet.
# - Always be cautious and review scripts from untrusted sources before running them.
# - For enhanced security, you could manually download the build script and verify
#   its contents and checksum before execution.
#

set -e

# URL of the build script in the repository
# TODO: Update with the actual URL when the repository is public
BUILD_SCRIPT_URL="https://raw.githubusercontent.com/your-repo/nvim-dev-env/main/build.sh"

# Download and execute the build script
echo "Downloading and running the build script..."
bash -c "$(curl -fsSL "$BUILD_SCRIPT_URL")"
