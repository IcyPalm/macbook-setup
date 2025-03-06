#!/bin/bash
########################
# make-symlinks.sh
#
# This script creates symlinks from the home directory to any desired
# dotfiles in ~/dotfiles.
#
# Heavily inspired by
# https://github.com/ericjaychi/sample-dotfiles/blob/master/make-symlinks.sh
########################

######## Variables

# Parent directory for this file
# https://stackoverflow.com/questions/9889938/shell-script-current-directory
DIR="$(cd "$(dirname "$0")" && pwd)"

# Directory containing repo's dotfiles
FILES_DIR=${DIR}/files

# Directory where old files will go as a backup
BAK_DIR=${DIR}_bak

######## Logic

# Create the backup directory
echo -n "Creating $BAK_DIR for backups of existing dotfiles …"
mkdir -p $BAK_DIR
echo "done"

# Navigate to the dotfiles directory
echo -n "Changing to $FILES_DIR …"
cd $FILES_DIR
echo "done"

# Special handling for Karabiner (symlink the whole directory)
# See documentation about this: https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/
KARABINER_TARGET="$HOME/.config/karabiner"
KARABINER_SOURCE="$FILES_DIR/config/karabiner"

if [ -d "$KARABINER_SOURCE" ]; then
    if [ -L "$KARABINER_TARGET" ]; then
        echo "Karabiner symlink already exists: $(readlink "$KARABINER_TARGET")"
    else
        echo "Handling Karabiner config: moving existing ~/.config/karabiner to backup"
        mv "$KARABINER_TARGET" "$BAK_DIR" 2>/dev/null

        echo "Creating symlink for Karabiner: $KARABINER_TARGET -> $KARABINER_SOURCE"
        ln -s "$KARABINER_SOURCE" "$KARABINER_TARGET"
    fi
fi

# Move existing dotfiles to backup and create symlinks (excluding Karabiner)
find . -type f ! -path "./config/karabiner/*" | while read -r file; do
    # Remove leading './' from filename
    relative_path="${file#./}"

    # Define the target location in the home directory
    target="$HOME/.$relative_path"

    if [ -L "$target" ]; then
        # If it's already a symlink, show where it points
        echo "Symlink already exists: $target -> $(readlink "$target")"
    else
        # Ensure the parent directory exists
        target_dir=$(dirname "$target")
        mkdir -p "$target_dir"

        echo "Moving existing dotfile from $target to $BAK_DIR if it exists"
        mv "$target" "$BAK_DIR" 2>/dev/null

        echo "Creating symlink: $target -> $FILES_DIR/$relative_path"
        ln -s "$FILES_DIR/$relative_path" "$target"
    fi
done