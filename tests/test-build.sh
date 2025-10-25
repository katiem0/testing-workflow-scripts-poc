#!/bin/bash
# Test suite for build.sh

SCRIPT_PATH=".github/scripts/build.sh"

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

test_runs_npm_build() {
  grep -q "npm run build" "$SCRIPT_PATH"
  assertTrue "Script should run 'npm run build'" $?
}

test_checks_package_json() {
  grep -q "package.json" "$SCRIPT_PATH"
  assertTrue "Script should check for package.json before building" $?
}

test_uses_build_dir_variable() {
  grep -q 'BUILD_DIR' "$SCRIPT_PATH"
  assertTrue "Script should reference BUILD_DIR variable" $?
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
