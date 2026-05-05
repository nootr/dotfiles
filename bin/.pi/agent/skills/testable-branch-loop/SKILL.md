---
name: testable-branch-loop
description: Start implementation work by grilling the user, creating a fresh branch from latest main/master, then iterating in a simple Ralph Wiggum-style test-first loop until the definition of done is verified. Use when starting a feature, bugfix, refactor, or implementation task that should be testable and safely scoped.
---

# Testable Branch Loop

Use this workflow for implementation tasks where the goal is to clarify scope, branch safely from the latest base branch, and iterate until a testable definition of done is met.

## Phase 1 — Grill first

Before changing code, run a grill-me style clarification pass.

If the `grill-me` skill is available, read/load its `SKILL.md` and apply it. If it is not available or cannot be loaded, follow this equivalent behavior:

- Interview the user relentlessly until the goal, constraints, and success criteria are clear.
- Resolve each branch of the decision tree one by one.
- If a question can be answered by inspecting the codebase, inspect the codebase instead of asking.
- For every question, include your recommended answer.

Focus especially on testability:

- What observable behavior must change?
- What must explicitly stay the same?
- How can we verify success locally?
- Which tests should fail before the change and pass after?
- What edge cases matter?
- What is out of scope?
- What is the smallest useful slice?

Do not proceed to branch creation until there is a concise Definition of Done.

## Phase 2 — Define Done

Write a short Definition of Done before implementation:

- Functional behavior expected.
- Tests/checks that must pass.
- Manual verification steps, if automated tests are not enough.
- Non-goals/out-of-scope items.
- Stop condition: when these checks pass, stop iterating and report completion.

If no meaningful automated verification exists, say that explicitly and ask whether to add tests, use manual verification, or continue with reduced confidence.

## Phase 3 — Branch from latest main/master

Create a new branch from the latest base branch.

1. Check worktree state:
   ```bash
   git status --short --branch
   ```
2. If there are uncommitted changes, stop and ask the user whether to stash, commit, keep working on the current branch, or abort.
3. Refresh remote refs before choosing a base branch:
   ```bash
   git fetch origin --prune
   ```
4. Determine the base branch from fresh remote refs:
   - Prefer `main` if `origin/main` exists.
   - Otherwise use `master` if `origin/master` exists.
   - If neither exists, inspect remotes and ask the user.
   Useful checks:
   ```bash
   git show-ref --verify --quiet refs/remotes/origin/main
   git show-ref --verify --quiet refs/remotes/origin/master
   ```
5. Choose a descriptive branch name derived from the task, unless the user provides one. Ask before creating the branch if the branch name is unclear.
6. Validate the branch name and ensure it does not already exist locally:
   ```bash
   git check-ref-format --branch <new-branch-name>
   git show-ref --verify --quiet refs/heads/<new-branch-name>
   ```
   If the local branch already exists, stop and ask whether to use it, choose another name, or abort.
7. Create a new branch from the fetched base:
   ```bash
   git checkout -b <new-branch-name> origin/<base-branch>
   ```

Do not use `git reset --hard` or overwrite local work without explicit confirmation.

## Phase 4 — Ralph Wiggum loop

Iterate in small, obvious steps. Prefer boring, testable changes over clever rewrites.

Loop:

1. State the current hypothesis in simple terms: "I think the next tiny step is ..."
2. Add or update the smallest useful test/check first when practical.
3. Run the targeted test/check and observe the result.
4. Make the smallest code change to move toward green.
5. Run the targeted test/check again.
6. If it passes, run broader relevant checks.
7. Compare the result against the Definition of Done.
8. Stop when the Definition of Done is satisfied and verified.

Rules for the loop:

- Keep changes small and reversible.
- Prefer one failing test, one implementation step, one verification cycle.
- If a check fails, inspect the failure before changing code.
- If the plan becomes invalid, pause and ask or re-grill the relevant decision.
- If implementation succeeds earlier than expected, stop; do not keep polishing without a reason.
- Do not call something fixed, done, working, or solved unless the relevant checks passed.
- If something was not tested, say so explicitly.

## Phase 5 — Final report

Report concisely:

- Branch name and base branch.
- Definition of Done.
- Files changed.
- Tests/checks run and their results.
- What was not tested, if anything.
- Any remaining risks or follow-up suggestions.

Never claim success beyond what was actually verified.
