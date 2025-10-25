#!/bin/bash
set -e

if [ -d coverage ]; then
  grep -R "Statements" coverage/**/index.html || true
  echo "Coverage artifacts collected"
else
  echo "No coverage directory"
fi
