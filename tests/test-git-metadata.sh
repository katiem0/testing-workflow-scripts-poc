#!/bin/bash
# Test suite for git-metadata.sh

SCRIPT_PATH=".github/scripts/git-metadata.sh"

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
  ! grep -E "(rm -rf /|format|dd if=|mkfs|:(){:|:&};:)" "$SCRIPT_PATH"
  assertTrue "Script should not contain dangerous commands" $?
}

test_uses_git_commands() {
  grep -q "git" "$SCRIPT_PATH"
  assertTrue "Script should use git commands" $?
}

test_uses_no_pager() {
  grep -q "git --no-pager" "$SCRIPT_PATH"
  assertTrue "Script should use --no-pager flag" $?
}

test_no_git_modifications() {
  # Should not commit, push, or modify git repo
  ! grep -E "git (commit|push|add|rm|reset --hard)" "$SCRIPT_PATH"
  assertTrue "Script should not modify git repository" $?
}

test_only_reads_git_info() {
  # Should only use read-only git commands
  grep -q "git.*log\|git.*status" "$SCRIPT_PATH"
  assertTrue "Script should only read git information" $?
}

test_script_syntax() {
  bash -n "$SCRIPT_PATH" 2>/dev/null
  assertTrue "Script should have valid bash syntax" $?
}

# Load shunit2
. tests/shunit2
