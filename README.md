# Workflow Testing POC

A proof-of-concept repository demonstrating how to refactor GitHub Actions workflows from inline bash
scripts to modular, testable script files with comprehensive security testing.

## Overview

This repository showcases the migration from monolithic workflow files with inline bash scripts to a modular architecture where:
- Each bash operation is extracted into a separate, testable script
- Security tests validate all scripts before they run in CI
- Scripts are reusable across multiple workflows

## Repository Structure

```
.
├── .github/
│   ├── scripts/              # Modular bash scripts
│   │   ├── print-context.sh
│   │   ├── show-environment.sh
│   │   ├── ...
│   └── workflows/
│       ├── ci-reusable.yml           # Original workflow (inline scripts)
│       ├── revamp-ci-reusable.yml    # Refactored workflow (modular scripts)
│       └── script-tests.yml          # Unit testing workflow
├── tests/
│   ├── run-all-tests.sh              # Test runner
│   ├── test-all-scripts.sh           # Comprehensive test suite
│   ├── test-print-context.sh         # Individual script tests
│   ├── ...
├── .gitignore
├── SECURITY-TESTING.md               # Unit testing documentation
└── README.md
```

## Migration Guide: From Inline to Modular Scripts

### Before: ci-reusable.yml (Inline Scripts)

The original [.github/workflows/ci-reusable.yml](.github/workflows/ci-reusable.yml) workflow contains all bash logic inline:

```yaml
- name: Install dependencies
  shell: bash
  run: |
    set -eux
    npm ci
    npm prune
```

### After: revamp-ci-reusable.yml (Modular Scripts)

The refactored [.github/workflows/revamp-ci-reusable.yml](.github/workflows/revamp-ci-reusable.yml) calls external scripts:

```yaml
- name: Install dependencies
  run: ./.github/scripts/install-deps.sh
```

## Unit Testing Framework

### Test Suite Overview

The testing framework uses [shunit2](https://github.com/kward/shunit2) to validate all scripts for security vulnerabilities and correctness.

### Running Tests Locally

```bash
# Run all tests
./tests/run-all-tests.sh

# Run specific test file
./tests/test-install-deps.sh

# Run comprehensive security checks only
./tests/test-all-scripts.sh
```

### Test Coverage

Each script has its own test file that validates:

**Example: [test-install-deps.sh](tests/test-install-deps.sh)**
```bash
test_uses_npm_ci() {
  grep -q "npm ci" "$SCRIPT_PATH"
  assertTrue "Script should use 'npm ci' for reproducible installs" $?
}

test_no_global_npm_install() {
  ! grep -q "npm.*-g\|npm.*--global" "$SCRIPT_PATH"
  assertTrue "Script should not install packages globally" $?
}
```

**Example: [test-pre-build-cleanup.sh](tests/test-pre-build-cleanup.sh)**
```bash
test_no_dangerous_rm_commands() {
  ! grep -E "rm -rf /[^a-zA-Z]|rm -rf /\$" "$SCRIPT_PATH"
  assertTrue "Script should not contain 'rm -rf /'" $?
}

test_uses_variable_for_rm() {
  grep -q 'rm -rf.*\${BUILD_DIR}' "$SCRIPT_PATH"
  assertTrue "Script should use BUILD_DIR variable for removal" $?
}
```

### CI Integration

The [.github/workflows/script-tests.yml](.github/workflows/script-tests.yml) workflow automatically runs tests on:

- Pull requests that modify scripts or workflows
- Pushes to main branch
- Manual workflow dispatch

```yaml
on:
  pull_request:
    paths:
      - '.github/scripts/**'
      - '.github/workflows/**'
      - 'tests/**'
```

**Test Steps:**
1. Download shunit2 testing framework
2. Make all test scripts executable
3. Run comprehensive security test suite
4. Verify no dangerous patterns exist
5. Confirm all scripts are executable
6. Validate bash syntax for all scripts
7. Generate summary in GitHub Actions UI

## Further Reading

- [.github/workflows/script-tests.yml](.github/workflows/script-tests.yml) - CI testing workflow
- [shunit2 Documentation](https://github.com/kward/shunit2) - Testing framework
