#!/bin/bash
set -e

echo "Job conclusion: ${{ job.status }}"
echo "Workflow: ${{ github.workflow }}"
echo "Run number: ${{ github.run_number }}"
echo "Done."
