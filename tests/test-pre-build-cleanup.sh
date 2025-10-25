#!/bin/bash
# Test suite for pre-build-cleanup.sh

SCRIPT_PATH=".github/scripts/pre-build-cleanup.sh"

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
  grep -q "set -e" "$SCRIPT_PATH"
  assertTrue "Script should use 'set -e' for error handling" $?
}

test_no_dangerous_rm_commands() {
  # Should not have rm -rf / or rm -rf /*
  ! grep -E "rm -rf /[^a-zA-Z]|rm -rf /\$" "$SCRIPT_PATH"
  assertTrue "Script should not contain 'rm -rf /'" $?
}

test_uses_variable_for_rm() {
  # rm should only target the BUILD_DIR variable, not hardcoded paths
  grep -q 'rm -rf.*\${BUILD_DIR}' "$SCRIPT_PATH"
  assertTrue "Script should use BUILD_DIR variable for removal" $?
}

test_mkdir_uses_variable() {
  # mkdir should also use the BUILD_DIR variable
  grep -q 'mkdir -p.*\${BUILD_DIR}' "$SCRIPT_PATH"
  assertTrue "Script should use BUILD_DIR variable for directory creation" $?
}

test_no_absolute_paths_in_rm() {
  # Should not use absolute paths like /tmp, /usr, etc.
  ! grep -E "rm.*(/usr|/etc|/var|/tmp|/home|/root)" "$SCRIPT_PATH"
  assertTrue "Script should not remove absolute system paths" $?
}

test_no_wildcard_rm_at_root() {
  # Should not have dangerous wildcards
  ! grep -E "rm -rf \\*|rm -rf /\\*|rm -rf ~/\\*" "$SCRIPT_PATH"
  assertTrue "Script should not use dangerous wildcards with rm" $?
}

test_script_syntax() {
  bash -n "$SCRIPT_PATH" 2>/dev/null
  assertTrue "Script should have valid bash syntax" $?
}

# Load shunit2
. tests/shunit2
