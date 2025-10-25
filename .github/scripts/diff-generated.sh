#!/bin/bash
set -eux

if [ -f package.json ]; then
  npm run build || true
  git diff --name-only "${BUILD_DIR}" || true
fi
