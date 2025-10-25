#!/bin/bash
# Test suite for show-environment.sh

SCRIPT_PATH=".github/scripts/show-environment.sh"

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
  grep -q "set -euxo pipefail" "$SCRIPT_PATH"
  assertTrue "Script should use 'set -euxo pipefail' for safety" $?
}

test_no_dangerous_commands() {
  ! grep -E "(rm -rf /|format|dd if=|mkfs|:(){:|:&};:|eval)" "$SCRIPT_PATH"
  assertTrue "Script should not contain dangerous commands" $?
}

test_only_displays_info() {
  # Should only echo and run uname, no destructive operations
  ! grep -E "(rm|mv|cp|chmod|chown|curl.*-o|wget.*-O)" "$SCRIPT_PATH"
  assertTrue "Script should only display information" $?
}

test_uses_safe_commands() {
  grep -q "echo\|uname" "$SCRIPT_PATH"
  assertTrue "Script should use safe display commands" $?
}

test_script_syntax() {
  bash -n "$SCRIPT_PATH" 2>/dev/null
  assertTrue "Script should have valid bash syntax" $?
}

# Load shunit2
. tests/shunit2
