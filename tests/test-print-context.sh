#!/bin/bash
# Test suite for print-context.sh

# Source the script in a way that allows testing
SCRIPT_PATH=".github/scripts/print-context.sh"

test_script_exists() {
  assertTrue "Script should exist" "[ -f $SCRIPT_PATH ]"
}

test_script_is_executable() {
  assertTrue "Script should be executable" "[ -x $SCRIPT_PATH ]"
}

test_script_has_shebang() {
  local first_line=$(head -n 1 "$SCRIPT_PATH")
  assertEquals "Script should have bash shebang" "#!/bin/bash" "$first_line"
}

test_script_uses_safe_options() {
  # Check that script uses 'set -e' for error handling
  grep -q "set -e" "$SCRIPT_PATH"
  assertTrue "Script should use 'set -e' for error handling" $?
}

test_no_dangerous_commands() {
  # Ensure script doesn't contain dangerous commands
  ! grep -E "(rm -rf /|format|dd if=|mkfs|:(){:|:&};:)" "$SCRIPT_PATH"
  assertTrue "Script should not contain dangerous commands" $?
}

test_only_echo_commands() {
  # This script should only echo information, not modify anything
  ! grep -E "(rm|mv|cp|chmod|chown|curl|wget|eval)" "$SCRIPT_PATH"
  assertTrue "Script should only use safe echo commands" $?
}

test_uses_github_vars() {
  # Verify it references GitHub environment variables
  grep -q "GITHUB_REPOSITORY\|GITHUB_REF\|GITHUB_SHA" "$SCRIPT_PATH"
  assertTrue "Script should reference GitHub environment variables" $?
}

test_script_syntax() {
  bash -n "$SCRIPT_PATH" 2>/dev/null
  assertTrue "Script should have valid bash syntax" $?
}

# Load shunit2
. tests/shunit2
