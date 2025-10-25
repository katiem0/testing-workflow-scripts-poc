#!/bin/bash
set -eux

if [ -f tsconfig.json ]; then
  npx tsc -p tsconfig.json --noEmit
else
  echo "No tsconfig.json; skipping type check"
fi
