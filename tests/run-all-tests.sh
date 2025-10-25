#!/bin/bash
# Runner script to execute all test suites

set -e

echo "==================================="
echo "Running Security Tests for Scripts"
echo "==================================="
echo ""

# Check if shunit2 is available
if [[ ! -f "tests/shunit2" ]]; then
  echo "Downloading shunit2 testing framework..."
  curl -sSL https://raw.githubusercontent.com/kward/shunit2/master/shunit2 -o tests/shunit2
  chmod +x tests/shunit2
fi

# Run comprehensive test suite
echo "Running comprehensive security checks..."
bash tests/test-all-scripts.sh

echo ""
echo "Running individual script tests..."
echo ""

# Run individual test files
for test_file in tests/test-*.sh; do
  if [[ "$test_file" != "tests/test-all-scripts.sh" ]]; then
    echo "Running $test_file..."
    bash "$test_file"
    echo ""
  fi
done

echo "==================================="
echo "All tests completed!"
echo "==================================="
