#!/bin/bash
# script extracts the first frame from an XYZ atomic coordinate file

### set IFS to empty or use double quotes for echo
###https://unix.stackexchange.com/questions/164508/why-do-newline-characters-get-lost-when-using-command-substitution
#IFS=

### get number of atoms from xyz file $1 (commandline file1)
numAtoms=$(head -n 1 $1)
#echo "Number of atoms: " $numAtoms

### add 2 lines and get head of file
echo "$(head -n $((numAtoms+2)) $1)"
