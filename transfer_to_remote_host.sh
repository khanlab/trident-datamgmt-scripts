#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <source_folder1> <source_folder2> ... <destination_folder> <user@hostname>"
    exit 1
fi

# Get the destination folder (second last argument) and the destination user@hostname (last argument)
DEST_FOLDER="${@: -2:1}"
DEST_USER_HOST="${@: -1}"

# Iterate over all source folders (all arguments except the last two)
for SRC_FOLDER in "${@:1:$#-2}"; do
    # Get the folder name without the leading path (for tar file naming)
    FOLDER_NAME=$(basename "$SRC_FOLDER")

    # Calculate the total size of the folder for progress estimation
    TOTAL_SIZE=$(du -sb "$SRC_FOLDER" | cut -f1)
    
    # Create the tar file with only the contents of the source folder, pipe through pv for progress, and transfer over SSH
    tar -C "$SRC_FOLDER" -cf - . | pv -s "$TOTAL_SIZE" | ssh "$DEST_USER_HOST" "cat > $DEST_FOLDER/$FOLDER_NAME.tar"
    
    if [ $? -eq 0 ]; then
        echo "Successfully transferred $SRC_FOLDER to $DEST_USER_HOST:$DEST_FOLDER/$FOLDER_NAME.tar"
    else
        echo "Error transferring $SRC_FOLDER"
    fi
done

