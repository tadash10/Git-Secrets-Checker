#!/bin/bash

# Define the regex patterns for secrets
PATTERNS=("password" "api_key" "access_key" "secret_key" "token" "passphrase" "key" "credential" "auth")

# Set up variables for ISO 27001 compliance
LOG_FILE="./git-secrets-checker.log"
NOTIFY_EMAIL="security@yourcompany.com"

# Display a disclaimer and wait for the user to acknowledge it
echo "DISCLAIMER: This tool is provided as-is and may generate false positives or false negatives. Use at your own risk."
read -p "Press enter to continue or Ctrl+C to exit."

# Display a menu with options for running the tool
while true; do
  echo ""
  echo "Git Secrets Checker Menu:"
  echo "1. Check the current commit"
  echo "2. Check the entire repository"
  echo "3. Exit"
  read -p "Enter your choice (1-3): "

  case $REPLY in
    1) # Check the current commit
      files=$(git diff-tree --no-commit-id --name-only HEAD^ HEAD)
      ;;
    2) # Check the entire repository
      files=$(git diff-tree --no-commit-id --name-only -r HEAD)
      ;;
    3) # Exit the script
      exit 0
      ;;
    *) # Invalid input
      echo "Invalid input. Please enter a number from 1 to 3."
      continue
      ;;
  esac

  # Check each file for secrets
  for file in $files; do
    for pattern in ${PATTERNS[@]}; do
      if grep -qi $pattern $file; then
        # Log the secret and notify the security team
        echo "$(date): Secret found in $file" >> $LOG_FILE
        grep -ni $pattern $file >> $LOG_FILE
        mail -s "Git Secrets Checker Alert" $NOTIFY_EMAIL < $LOG_FILE
        rm $LOG_FILE
        # Exit with a non-zero status code to indicate a secret was found
        exit 1
      fi
    done
  done

  echo "No secrets found."
done
