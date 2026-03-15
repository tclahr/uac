# Run Command Eval Injection Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove `eval` from `_run_command`, keep explicit shell execution available only through a clearly named helper, and add regression coverage for the direct command-injection PoC.

**Architecture:** `_run_command` will become an argv-style executor that runs a command and its arguments without reparsing a shell fragment. A new `_run_shell_command` helper will retain current shell-fragment behavior for trusted internal callers that need pipelines, compound commands, or shell syntax. Existing call sites that intentionally build shell fragments will be migrated to `_run_shell_command`, while the regression test will prove that direct `_run_command` use no longer executes injected shell substitutions.

**Tech Stack:** POSIX shell, existing UAC library loader, shellcheck, repo-local shell regression tests, GitHub Actions workflow for regression checks.

---

### Task 1: Add the failing regression

**Files:**
- Create: `tests/security/test_run_command_injection.sh`
- Modify: `.github/workflows/security-regression-tests.yaml`

**Step 1: Write the failing test**

Add a self-contained shell test that:
- creates a temp work directory
- loads `lib/load_libraries.sh`
- writes the literal payload `$(touch${IFS}COMMAND_EXECUTED)` to a file
- embeds that payload into a command string
- calls `_run_command "${command}" true`
- expects no marker file to be created
- exits non-zero on current `origin/main`

**Step 2: Run test to verify it fails**

Run: `sh tests/security/test_run_command_injection.sh`
Expected: FAIL because `_run_command` still uses `eval` and the marker file is created.

**Step 3: Add workflow coverage**

Create a focused GitHub Actions workflow that runs the new regression test on pull requests to `main` and `develop`.

**Step 4: Commit checkpoint**

Do not commit yet if the test still fails for the expected reason; move straight to implementation once the failing behavior is verified.

### Task 2: Implement the execution split

**Files:**
- Modify: `lib/run_command.sh`
- Modify: `lib/command_collector.sh`
- Modify: `lib/find_based_collector.sh`
- Modify: `lib/parse_artifact.sh`

**Step 1: Write the minimal production change**

Update `lib/run_command.sh` so:
- `_run_command` executes `"$@"` directly, preserving the optional stderr redirection behavior without `eval`
- `_run_shell_command` accepts the old string-based command contract and runs it through `sh -c`
- logging still records the executed command and stderr text in a readable way

**Step 2: Migrate shell-fragment callers**

Update callers that currently pass shell fragments, not argv lists:
- `lib/command_collector.sh`
- `lib/find_based_collector.sh`
- `lib/parse_artifact.sh`

Each migrated site should call `_run_shell_command` explicitly. Avoid opportunistic refactors.

**Step 3: Keep behavior stable**

Preserve:
- command output capture
- stderr redirection semantics
- existing verbose logging
- current collector file-output behavior

**Step 4: Run focused verification**

Run:
- `sh tests/security/test_run_command_injection.sh`
- `sh -n lib/run_command.sh lib/command_collector.sh lib/find_based_collector.sh lib/parse_artifact.sh tests/security/test_run_command_injection.sh`
- `shellcheck lib/run_command.sh lib/command_collector.sh lib/find_based_collector.sh lib/parse_artifact.sh tests/security/test_run_command_injection.sh`

Expected: all pass.

### Task 3: Verify behavior and guard against regressions

**Files:**
- Review only unless fixes are needed in the files above

**Step 1: Re-run the original PoC against the worktree**

Run the equivalent of the direct PoC against this branch and verify that the marker file is not created.

**Step 2: Spot-check internal shell execution**

Run a small targeted script or existing commands to verify that `_run_shell_command` still handles a pipeline or simple shell fragment correctly.

**Step 3: Inspect git diff**

Run: `git diff --stat` and `git diff -- lib/run_command.sh lib/command_collector.sh lib/find_based_collector.sh lib/parse_artifact.sh tests/security/test_run_command_injection.sh .github/workflows/security-regression-tests.yaml`

Expected: only the intended execution split, caller migration, and regression coverage changes.

### Task 4: Review, commit, and open the PR from `mobasi-team`

**Files:**
- No new files expected unless review finds issues

**Step 1: Request code review**

Use the review workflow to inspect the changed files for regressions in command execution, logging, and test coverage.

**Step 2: Final verification before claiming success**

Re-run the full targeted verification suite from Task 2 and confirm the PoC remains blocked.

**Step 3: Commit**

Run:
- `git add lib/run_command.sh lib/command_collector.sh lib/find_based_collector.sh lib/parse_artifact.sh tests/security/test_run_command_injection.sh .github/workflows/security-regression-tests.yaml docs/plans/2026-03-15-run-command-eval-injection.md`
- `git commit -m "fix: split shell execution from run_command"`

**Step 4: Push and create PR**

Push the branch to `mobasi-team` and open the upstream pull request against `tclahr/uac:main`, making sure the PR comes from `mobasi-team`, not `jsinge97`.
