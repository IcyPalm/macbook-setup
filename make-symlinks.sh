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

# Move any existing dotfiles in homedir to the backup directory, then
# create symlinks from the homedir to any files in the dotfiles
# directory.
for item in *; do
    echo "Moving any existing dotfiles from ~ to $BAK_DIR"
    mv ~/.$item $BAK_DIR
    echo "Creating symlink to $item in home directory."
    ln -s $FILES_DIR/$item ~/.$item
done
