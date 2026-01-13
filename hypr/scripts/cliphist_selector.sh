#!/bin/bash
cliphist list | awk '{ $1=""; line = substr($0, 2); if (length(line) > 30) { print substr(line, 1, 30) "..." } else { print line } }' | wofi --dmenu | cliphist decode | wl-copy
