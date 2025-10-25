#!/bin/bash
# Test suite for run-tests.sh

SCRIPT_PATH=".github/scripts/run-tests.sh"

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
  ! grep -E "(rm -rf /|format|dd if=|mkfs|:(){:|:&};:)" "$SCRIPT_PATH"
  assertTrue "Script should not contain dangerous commands" $?
}

test_runs_npm_test() {
  grep -q "npm test" "$SCRIPT_PATH"
  assertTrue "Script should run 'npm test'" $?
}

test_uses_ci_flag() {
  grep -q -- "--ci" "$SCRIPT_PATH"
  assertTrue "Script should use --ci flag for CI environment" $?
}

test_no_arbitrary_code_execution() {
  ! grep -E "(eval|source \\$|\\. \\$)" "$SCRIPT_PATH"
  assertTrue "Script should not execute arbitrary code" $?
}

test_script_syntax() {
  bash -n "$SCRIPT_PATH" 2>/dev/null
  assertTrue "Script should have valid bash syntax" $?
}

# Load shunit2
. tests/shunit2
