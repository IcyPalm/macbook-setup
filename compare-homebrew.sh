#!/bin/bash

set -euo pipefail

BREW_DIR="$(cd "$(dirname "$0")/homebrew" && pwd)"
FORMULAE_FILE="$BREW_DIR/homebrew-formulae.txt"
CASKS_FILE="$BREW_DIR/homebrew-casks.txt"
PERSONAL_CASKS_FILE="$BREW_DIR/homebrew-casks-personal.txt"

INCLUDE_PERSONAL=false
for arg in "$@"; do
    [[ "$arg" == "--personal" ]] && INCLUDE_PERSONAL=true
done

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

compare() {
    local label="$1"
    shift
    local installed

    local all_installed leaves
    if [[ "$label" == "Formulae" ]]; then
        all_installed="$(brew list --formula | sort)"
        leaves="$(brew leaves | sort)"
    else
        all_installed="$(brew list --cask | sort)"
        leaves="$all_installed"
    fi

    local repo
    repo="$(for f in "$@"; do cat "$f"; echo; done | grep -v '^\s*$' | sort)"

    local only_installed only_repo

    # In repo but not installed (check against full install list, not just leaves)
    only_repo="$(comm -23 <(echo "$repo") <(echo "$all_installed"))"
    # Installed but not in repo (only flag top-level packages, not dependencies)
    only_installed="$(comm -13 <(echo "$repo") <(echo "$leaves"))"

    echo -e "${BOLD}── $label ──────────────────────────────────────────${RESET}"

    if [[ -z "$only_repo" && -z "$only_installed" ]]; then
        echo -e "  ${GREEN}✓ In sync${RESET}"
    else
        if [[ -n "$only_repo" ]]; then
            echo -e "  ${YELLOW}In repo, not installed:${RESET}"
            while IFS= read -r pkg; do
                echo "    - $pkg"
            done <<< "$only_repo"
        fi
        if [[ -n "$only_installed" ]]; then
            echo -e "  ${RED}Installed, not in repo:${RESET}"
            while IFS= read -r pkg; do
                echo "    + $pkg"
            done <<< "$only_installed"
        fi
    fi
    echo ""
}

compare "Formulae" "$FORMULAE_FILE"

if [[ "$INCLUDE_PERSONAL" == true ]]; then
    compare "Casks" "$CASKS_FILE" "$PERSONAL_CASKS_FILE"
else
    compare "Casks" "$CASKS_FILE"
fi
