#!/bin/bash
set -eux

npm ci
npm prune
