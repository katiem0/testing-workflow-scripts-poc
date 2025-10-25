#!/bin/bash
set -eux

tar czf build-${TIMESTAMP}.tar.gz "${BUILD_DIR}"
echo "Archive created: build-${TIMESTAMP}.tar.gz"
ls -lh build-${TIMESTAMP}.tar.gz
