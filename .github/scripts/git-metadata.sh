#!/bin/bash
set -e

git --no-pager log -1 --pretty=oneline
git status --short
