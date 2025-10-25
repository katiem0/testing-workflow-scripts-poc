#!/bin/bash
set -e

if npx prettier -v >/dev/null 2>&1; then
  npx prettier -c "**/*.{js,ts,jsx,tsx,json,md,yml}" || echo "Formatting differences found"
else
  echo "Prettier not installed"
fi
