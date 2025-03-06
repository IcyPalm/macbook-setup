#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Directories and files
BREW_DIR="$(pwd)/homebrew"
FORMULAE_FILE="$BREW_DIR/homebrew-formulae.txt"
CASKS_FILE="$BREW_DIR/homebrew-casks.txt"
PERSONAL_CASKS_FILE="$BREW_DIR/homebrew-casks-personal.txt"

INSTALL_PERSONAL=false

# Parse flags
for arg in "$@"; do
    case $arg in
        --personal)
            INSTALL_PERSONAL=true
            shift # Remove --personal from processing
            ;;
    esac
done

# Function to check if a formula is installed
is_formula_installed() {
    brew list --formula | grep -q "^$1$"
}

# Function to check if a cask is installed
is_cask_installed() {
    brew list --cask | grep -q "^$1$"
}

# Function to display interactive exclusion menu
select_casks_to_exclude() {
    local cask_file=$1
    local options=($(cat "$cask_file"))
    local selected_casks=()
    
    echo "Installing gum for interactive selection..."
    brew install gum || echo "Failed to install gum, falling back to manual selection."
    
    if command -v gum &> /dev/null; then
        echo "Select casks to install (use space to toggle selection, enter to confirm):"
        selected_casks=($(printf "%s\n" "${options[@]}" | gum choose --no-limit))
    else
        echo "gum not found. Using manual selection."
        echo "Select casks you DO NOT want to install (enter numbers separated by spaces):"
        for i in "${!options[@]}"; do
            echo "$((i+1))) ${options[i]}"
        done
        read -r selections
        
        local excluded_casks=()
        for num in $selections; do
            excluded_casks+=("${options[$((num-1))]}")
        done
        
        for cask in "${options[@]}"; do
            if [[ ! " ${excluded_casks[@]} " =~ " $cask " ]]; then
                selected_casks+=("$cask")
            fi
        done
    fi

    echo "Installing selected casks: ${selected_casks[@]}"
    for cask in "${selected_casks[@]}"; do
        if ! is_cask_installed "$cask"; then
            echo "Installing $cask..."
            brew install --cask "$cask"
        else
            echo "$cask is already installed, skipping."
        fi
    done
}

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew..."
brew update

echo "Ensuring gum is installed..."
brew install gum || echo "Failed to install gum, proceeding with manual selection."

# Install formulae
if [ -f "$FORMULAE_FILE" ]; then
    echo "Installing formulae..."
    while IFS= read -r formula; do
        if ! is_formula_installed "$formula"; then
            echo "Installing $formula..."
            brew install "$formula"
        else
            echo "$formula is already installed, skipping."
        fi
    done < "$FORMULAE_FILE"
else
    echo "Formulae file not found: $FORMULAE_FILE"
fi

# Install casks with interactive selection
if [ -f "$CASKS_FILE" ]; then
    echo "Installing casks..."
    select_casks_to_exclude "$CASKS_FILE"
else
    echo "Casks file not found: $CASKS_FILE"
fi

# Install personal casks if flag is set
if [ "$INSTALL_PERSONAL" = true ]; then
    if [ -f "$PERSONAL_CASKS_FILE" ]; then
        echo "Installing personal casks..."
        select_casks_to_exclude "$PERSONAL_CASKS_FILE"
    else
        echo "Personal casks file not found: $PERSONAL_CASKS_FILE"
    fi
fi

echo "Homebrew setup complete!"
