#!/bin/bash

# Backup script for Pipe Network PoP node
# Version: 1.0.0
#
# This script creates backups of important node data
#
# NOTE: This script will use the global backup script if available,
# or fall back to the local implementation if the global script doesn't exist.
#
# Contributors:
# - Preterag Team (original implementation)
# - Community contributors welcome! See README.md for contribution guidelines

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Display version information
print_message "Pipe Network PoP Backup Tool v1.0.0"

# Check if the global backup script exists
if [ -f "/opt/pipe-pop/backup.sh" ]; then
    print_message "Using global backup script..."
    sudo /opt/pipe-pop/backup.sh
    exit $?
fi

print_message "Global backup script not found. Using local implementation..."

# Create backup directory if it doesn't exist
mkdir -p backups

# Get current timestamp for backup file
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_dir="backups/backup_${timestamp}"
mkdir -p "${backup_dir}"

# Backup node_info.json if it exists
if [ -f "cache/node_info.json" ]; then
    print_message "Backing up node_info.json..."
    cp "cache/node_info.json" "${backup_dir}/"
    print_message "node_info.json backed up successfully."
else
    print_warning "node_info.json not found. Skipping backup."
fi

# Backup Solana wallet if it exists
if [ -f "$HOME/.config/solana/id.json" ]; then
    print_message "Backing up Solana wallet..."
    cp "$HOME/.config/solana/id.json" "${backup_dir}/solana_id.json"
    print_message "Solana wallet backed up successfully."
else
    print_warning "Solana wallet not found. Skipping backup."
fi

# Backup configuration files
print_message "Backing up configuration files..."
if [ -d "config" ]; then
    cp -r config "${backup_dir}/"
    print_message "Configuration files backed up successfully."
else
    print_warning "Configuration directory not found. Skipping backup."
fi

# Create a compressed archive of the backup
print_message "Creating compressed archive..."
tar -czf "${backup_dir}.tar.gz" -C backups "backup_${timestamp}"

# Remove the uncompressed backup directory
rm -rf "${backup_dir}"

print_message "Backup completed successfully: ${backup_dir}.tar.gz"
print_message "Please store this backup in a safe location." 