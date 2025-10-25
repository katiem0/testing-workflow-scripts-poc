#!/bin/bash
set -e

test -f package.json || { echo "package.json missing"; exit 1; }
jq '.name, .version' package.json