#!/bin/bash

# Grab last frame of an xyz file
tail -$(( $(head -1 $1) + 2 )) $1
