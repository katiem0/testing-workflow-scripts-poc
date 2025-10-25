#!/bin/bash
set -euxo pipefail

if [ -f package.json ]; then
  npm run build || { echo "Build failed"; exit 1; }
fi
ls -R "${BUILD_DIR}" || echo "Build dir missing"
