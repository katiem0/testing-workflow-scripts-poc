#!/bin/bash
# Test suite for validate-manifest.sh

SCRIPT_PATH=".github/scripts/validate-manifest.sh"

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

test_no_dangerous_commands() {
  ! grep -E "(rm -rf /|format|dd if=|mkfs|:(){:|:&};:|eval)" "$SCRIPT_PATH"
  assertTrue "Script should not contain dangerous commands" $?
}

test_validates_package_json() {
  grep -q "package.json" "$SCRIPT_PATH"
  assertTrue "Script should check for package.json" $?
}

test_uses_jq_safely() {
  # Should use jq for JSON parsing, not eval
  grep -q "jq" "$SCRIPT_PATH"
  assertTrue "Script should use jq for JSON parsing" $?
  
  ! grep -q "eval" "$SCRIPT_PATH"
  assertTrue "Script should not use eval" $?
}

test_no_modification_commands() {
  # This script should only read, not modify
  ! grep -E "(rm|mv|cp|>|>>)" "$SCRIPT_PATH"
  assertTrue "Script should not modify files" $?
}

test_script_syntax() {
  bash -n "$SCRIPT_PATH" 2>/dev/null
  assertTrue "Script should have valid bash syntax" $?
}

# Load shunit2
. tests/shunit2
