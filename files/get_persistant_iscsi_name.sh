#!/bin/bash
test -n "$2" && id="$1_$2" || id="$1"
echo "$id" | cut -d : -f 4
