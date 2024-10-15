#!/bin/bash

# Find and display all "build" directories
build_dirs=$(find . -type d -name "build")

if [ -z "$build_dirs" ]; then
  echo "No directories named 'build' found."
  exit 0
fi

# Present the list to the user
echo "Found the following 'build' directories:"
echo "$build_dirs"
echo ""

# Prompt the user for confirmation
read -p "Do you want to delete these directories? (y/n): " choice

if [ "$choice" == "y" ]; then
  echo "Deleting directories..."
  # Delete the directories
  echo "$build_dirs" | xargs rm -rf
  echo "Deletion complete."
else
  echo "Aborted."
  exit 0
fi
