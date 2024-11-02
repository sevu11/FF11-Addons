#!/bin/bash

# Prompt the user for the prefix
read -p "Enter the prefix to add to the file names: " userinputname

# Loop through all files in the current directory
for file in *; do
    # Check if it is a file (not a directory)
    if [ -f "$file" ]; then
        # Rename the file by adding the prefix
        mv "$file" "${userinputname}_$file"
    fi
done

echo "Files have been renamed."

