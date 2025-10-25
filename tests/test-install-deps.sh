#!/bin/bash
# Test suite for install-deps.sh

SCRIPT_PATH=".github/scripts/install-deps.sh"

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
  grep -q "set -eux" "$SCRIPT_PATH"
  assertTrue "Script should use 'set -eux' for safety" $?
}

test_no_dangerous_commands() {
  ! grep -E "(rm -rf /|format|dd if=|mkfs|:(){:|:&};:)" "$SCRIPT_PATH"
  assertTrue "Script should not contain dangerous commands" $?
}

test_uses_npm_ci() {
  # Should use npm ci (clean install) not npm install
  grep -q "npm ci" "$SCRIPT_PATH"
  assertTrue "Script should use 'npm ci' for reproducible installs" $?
}

test_uses_npm_prune() {
  # Should clean up extraneous packages
  grep -q "npm prune" "$SCRIPT_PATH"
  assertTrue "Script should use 'npm prune' to remove extraneous packages" $?
}

test_no_arbitrary_code_execution() {
  # Should not use eval, source untrusted files, or execute arbitrary code
  ! grep -E "(eval|source \\$|\\. \\$|\\\$\\(curl|\\\$\\(wget)" "$SCRIPT_PATH"
  assertTrue "Script should not execute arbitrary code" $?
}

test_no_global_npm_install() {
  # Should not install packages globally
  ! grep -q "npm.*-g\|npm.*--global" "$SCRIPT_PATH"
  assertTrue "Script should not install packages globally" $?
}

test_script_syntax() {
  bash -n "$SCRIPT_PATH" 2>/dev/null
  assertTrue "Script should have valid bash syntax" $?
}

# Load shunit2
. tests/shunit2
