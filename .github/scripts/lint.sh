#!/bin/bash
set -eux

npx eslint . || (echo "Lint failed" && exit 1)
