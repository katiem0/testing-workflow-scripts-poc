#!/bin/bash
set -eux

npm audit --audit-level=moderate || echo "Audit found issues"
