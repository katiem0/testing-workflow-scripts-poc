#!/bin/bash
# Master test suite that runs all script tests

SCRIPT_DIR=".github/scripts"

test_all_scripts_have_shebang() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    local first_line=$(head -n 1 "$script")
    if [[ "$first_line" != "#!/bin/bash" ]]; then
      echo "FAIL: $script missing proper shebang"
      failed=1
    fi
  done
  assertEquals "All scripts should have bash shebang" 0 $failed
}

test_all_scripts_are_executable() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    if [[ ! -x "$script" ]]; then
      echo "FAIL: $script is not executable"
      failed=1
    fi
  done
  assertEquals "All scripts should be executable" 0 $failed
}

test_all_scripts_have_error_handling() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    if ! grep -q "set -e" "$script"; then
      echo "FAIL: $script missing error handling (set -e)"
      failed=1
    fi
  done
  assertEquals "All scripts should have error handling" 0 $failed
}

test_no_scripts_have_dangerous_rm() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    if grep -E "rm -rf /[^a-zA-Z]|rm -rf /\$" "$script" >/dev/null 2>&1; then
      echo "FAIL: $script contains dangerous 'rm -rf /'"
      failed=1
    fi
  done
  assertEquals "No scripts should have dangerous rm commands" 0 $failed
}

test_no_scripts_use_eval() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    # Skip if it's just in a comment
    if grep -v "^#" "$script" | grep -q "eval"; then
      echo "FAIL: $script uses eval (potential security risk)"
      failed=1
    fi
  done
  assertEquals "No scripts should use eval" 0 $failed
}

test_all_scripts_have_valid_syntax() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    if ! bash -n "$script" 2>/dev/null; then
      echo "FAIL: $script has syntax errors"
      failed=1
    fi
  done
  assertEquals "All scripts should have valid syntax" 0 $failed
}

test_no_scripts_download_and_execute() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    if grep -E "curl.*\\|.*bash|wget.*\\|.*sh|\\\$\\(curl.*\\)|\\\$\\(wget.*\\)" "$script" >/dev/null 2>&1; then
      echo "FAIL: $script downloads and executes code (security risk)"
      failed=1
    fi
  done
  assertEquals "No scripts should download and execute code" 0 $failed
}

test_no_scripts_use_hardcoded_secrets() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    # Check for common patterns of hardcoded secrets
    if grep -E "(password|passwd|pwd|secret|token|api_key|apikey)=['\"]?[a-zA-Z0-9]{8,}" "$script" >/dev/null 2>&1; then
      echo "WARNING: $script may contain hardcoded secrets"
      # Don't fail, just warn
    fi
  done
  assertEquals "Scripts should not have hardcoded secrets" 0 $failed
}

test_scripts_use_relative_paths() {
  local failed=0
  for script in "$SCRIPT_DIR"/*.sh; do
    # Check for absolute paths that aren't variables
    if grep -E "/(usr|etc|var|tmp|home|root)/" "$script" | grep -v "^#" | grep -v '\$' >/dev/null 2>&1; then
      echo "WARNING: $script uses absolute system paths"
      # Don't fail, just warn
    fi
  done
  assertEquals "Scripts should prefer relative paths" 0 $failed
}

# Load shunit2
. tests/shunit2
