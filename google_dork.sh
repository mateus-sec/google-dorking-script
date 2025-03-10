#!/bin/bash

# Google Dorking Script using Lynx
# This script allows searching for specific file types on a target website using Google dorks

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

# Function to display information messages
info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

# Function to display success messages
success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

# Function to display warning messages
warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Check if Lynx is installed
check_lynx() {
    if ! command -v lynx &> /dev/null; then
        error_exit "Lynx is not installed. Please install it and try again."
    else
        info "Lynx is installed at $(which lynx)"
    fi
}

# Function to display the file extension menu
display_menu() {
    echo -e "\n${BLUE}=== File Extension Menu ===${NC}"
    echo "1) PDF (pdf)"
    echo "2) Word Document (doc)"
    echo "3) Word Document XML (docx)"
    echo "4) Text File (txt)"
    echo "5) CSV File (csv)"
    echo "6) Excel Spreadsheet (xls)"
    echo "7) Excel Spreadsheet XML (xlsx)"
    echo "8) Zip Archive (zip)"
    echo "9) PowerPoint (ppt)"
    echo "10) PowerPoint XML (pptx)"
    echo "11) Backup Files (bak)"
    echo "12) Configuration Files (conf)"
    echo "13) SQL Files (sql)"
    echo "14) Log Files (log)"
}

# Function to get file extension based on menu choice
get_extension() {
    local choice=$1
    
    case $choice in
        1) echo "pdf" ;;
        2) echo "doc" ;;
        3) echo "docx" ;;
        4) echo "txt" ;;
        5) echo "csv" ;;
        6) echo "xls" ;;
        7) echo "xlsx" ;;
        8) echo "zip" ;;
        9) echo "ppt" ;;
        10) echo "pptx" ;;
        11) echo "bak" ;;
        12) echo "conf" ;;
        13) echo "sql" ;;
        14) echo "log" ;;
    esac
}

# Function to validate website format
validate_website() {
    local website=$1
    
    # Remove http:// or https:// if present
    website=$(echo "$website" | sed 's/^https\?:\/\///')
    
    # Remove trailing slash if present
    website=$(echo "$website" | sed 's/\/$//')
    
    echo "$website"
}

# Function to perform Google dork search
perform_search() {
    local site=$1
    local ext=$2
    local output_file="$site"_"$ext"_results.txt
    local temp_file=$(mktemp)
    local query="site:$site ext:$ext"
    
    info "Searching for $ext files on $site..."
    info "Using query: $query"
    
    # Run Google search with Lynx
    lynx --dump "https://google.com/search?&q=$query" > "$temp_file" 2>/dev/null
    
    if [ $? -ne 0 ]; then
        error_exit "Failed to execute Lynx. Check your network connection."
    fi
    
    # Extract URLs and clean results
    grep -o "https://www.google.com/url?q=.*" "$temp_file" | sed 's/https:\/\/www.google.com\/url?q=\([^&]*\).*/\1/g' | grep "\.$ext" | grep -v "google.com" | grep -v "gstatic.com" | grep -v "cache:" | sort -u > "$output_file"
    
    # Count results
    local result_count=$(wc -l < "$output_file")
    
    # Display results
    if [ "$result_count" -eq 0 ]; then
        warning "No $ext files found on $site"
        echo "" > "$output_file"
    else
        success "Found $result_count $ext files on $site"
        echo -e "\n${GREEN}Results:${NC}"
        cat "$output_file"
        success "Results saved to $output_file"
    fi
    
    # Clean up
    rm -f "$temp_file"
}

# Main function
main() {
    clear
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}=== Google Dorking Script Using Lynx ====${NC}"
    echo -e "${BLUE}============================================${NC}"
    
    # Check if Lynx is installed
    check_lynx
    
    # Get target website
    echo -ne "\nEnter target website (e.g., google.com): "
    read website
    
    if [ -z "$website" ]; then
        error_exit "Website cannot be empty."
    fi
    
    # Validate and clean website input
    website=$(validate_website "$website")
    
    # Display menu and get file extension
    display_menu
    read choice
    
    ext=$(get_extension "$choice")
    
    # Perform search
    perform_search "$website" "$ext"
    
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${GREEN}Thank you for using the Google Dorking Script!${NC}"
    echo -e "${BLUE}============================================${NC}"
}

# Run the main function
main

