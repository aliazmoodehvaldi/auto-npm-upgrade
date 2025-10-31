#!/bin/bash
# ============================================
# 🧩 npm Package Updater Script
# --------------------------------------------
# Version     : 0.1.0
# Author      : Ali Azmoodeh Valdi
# Created     : 2025-10-31
# Last Update : 2025-10-31
# License     : MIT
#
# Description :
#   This script automates checking for outdated npm packages in a Node.js project,
#   distinguishing between major, minor, and patch updates. It provides an
#   interactive workflow to selectively update packages while supporting:
#     - Exclusion of specific packages
#     - Automatic retry using --force
#     - Color-coded output for improved readability
#
# Requirements:
#   - Node.js & npm (>=14 recommended)
#   - jq (JSON processor for parsing npm outdated output)
#
# Usage:
#   ./script.sh
#
#   Optional: Create a `.npm-update-exclude` file in the project root to list
#   packages that should not be automatically updated.
# ============================================

set -e  # Exit immediately if a command fails

# --------------------------------------------
# Define color codes for output formatting
# --------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔍 Checking for outdated npm packages...${NC}"

# --------------------------------------------
# Check prerequisites: npm and jq must be installed
# --------------------------------------------
if ! command -v npm >/dev/null 2>&1; then
  echo -e "${RED}❌ npm is not installed. Please install npm first.${NC}"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo -e "${RED}❌ jq is not installed. Please install jq.${NC}"
  exit 1
fi

# --------------------------------------------
# Load excluded packages from .npm-update-exclude
# --------------------------------------------
EXCLUDE_FILE=".npm-update-exclude"
EXCLUDE_PACKAGES=()

if [ -f "$EXCLUDE_FILE" ]; then
  mapfile -t EXCLUDE_PACKAGES < "$EXCLUDE_FILE"
  echo -e "${YELLOW}⚙️  Excluding packages listed in ${EXCLUDE_FILE}:${NC}"
  for pkg in "${EXCLUDE_PACKAGES[@]}"; do
    echo -e "  - ${pkg}"
  done
fi

# --------------------------------------------
# Retrieve outdated packages in JSON format
# --------------------------------------------
outdated_json=$(npm outdated --json || true)

# If no outdated packages, exit
if [ -z "$outdated_json" ] || [ "$outdated_json" = "null" ]; then
  echo -e "${GREEN}✅ All packages are already up to date!${NC}"
  exit 0
fi

# --------------------------------------------
# Identify MAJOR updates (breaking changes)
# --------------------------------------------
major_updates=$(echo "$outdated_json" | jq -r 'to_entries[]
  | select((.value.latest | split(".")[0]|tonumber) > (.value.current | split(".")[0]|tonumber))
  | "\(.key) \(.value.current) \(.value.latest)"')

if [ -n "$major_updates" ]; then
  echo -e "\n${YELLOW}⚠️  Packages with MAJOR updates available:${NC}"
  printf "${CYAN}%-30s %-15s %-15s${NC}\n" "Package" "Current" "Latest"
  printf "%-30s %-15s %-15s\n" "------------------------------" "---------------" "---------------"

  # Loop through each major update and display
  while IFS= read -r line; do
    pkg=$(echo "$line" | awk '{print $1}')
    current=$(echo "$line" | awk '{print $2}')
    latest=$(echo "$line" | awk '{print $3}')
    printf "%-30s %-15s %-15s\n" "$pkg" "$current" "$latest"
  done <<< "$major_updates"
else
  echo -e "${GREEN}✅ No major updates found.${NC}"
fi

# --------------------------------------------
# Identify MINOR and PATCH updates
# --------------------------------------------
minor_patch_updates=$(echo "$outdated_json" | jq -r 'to_entries[]
  | select((.value.latest | split(".")[0]|tonumber) == (.value.current | split(".")[0]|tonumber))
  | "\(.key) \(.value.current) \(.value.latest)"')

PACKAGES_TO_UPDATE=()

if [ -n "$minor_patch_updates" ]; then
  echo -e "\n${CYAN}📦 Packages with minor/patch updates available:${NC}"
  printf "${CYAN}%-30s %-15s %-15s${NC}\n" "Package" "Current" "Latest"
  printf "%-30s %-15s %-15s\n" "------------------------------" "---------------" "---------------"

  # Loop through updates and skip excluded packages
  while IFS= read -r line; do
    pkg=$(echo "$line" | awk '{print $1}')
    current=$(echo "$line" | awk '{print $2}')
    latest=$(echo "$line" | awk '{print $3}')
    if printf '%s\n' "${EXCLUDE_PACKAGES[@]}" | grep -Fxq "$pkg"; then
      echo -e "${YELLOW}⏭️  Skipping excluded package: ${pkg}${NC}"
    else
      printf "%-30s %-15s %-15s\n" "$pkg" "$current" "$latest"
      PACKAGES_TO_UPDATE+=("$pkg")
    fi
  done <<< "$minor_patch_updates"

  # --------------------------------------------
  # Prompt user to update packages interactively
  # --------------------------------------------
  if [ "${#PACKAGES_TO_UPDATE[@]}" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No packages left to update after exclusions.${NC}"
  else
    echo -ne "\n${YELLOW}❓ Do you want to update these packages? (y/n): ${NC}"
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
      echo -e "\n${CYAN}⬆️  Updating packages...${NC}"

      # Update each package, retry with --force if necessary
      for pkg in "${PACKAGES_TO_UPDATE[@]}"; do
        echo -e "${CYAN}Updating ${pkg}...${NC}"
        if npm install "$pkg"@latest; then
          echo -e "${GREEN}✅ Successfully updated ${pkg}${NC}"
        else
          echo -e "${YELLOW}⚠️ Initial update failed, retrying with --force...${NC}"
          if npm install "$pkg"@latest --force; then
            echo -e "${GREEN}✅ Successfully updated ${pkg} with --force${NC}"
          else
            echo -e "${RED}❌ Failed to update ${pkg} even with --force${NC}"
          fi
        fi
      done
    else
      echo -e "${YELLOW}⚠️  Update cancelled by user.${NC}"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  No packages with minor/patch updates found to update.${NC}"
fi

# --------------------------------------------
# Script complete
# --------------------------------------------
echo -e "\n${GREEN}🎉 Update finished!${NC}"
