---
name: create-commit
description: Create or amend a git commit safely using repository commit conventions. Use when the user asks to commit changes, amend a commit, prepare a branch for push/MR, or fix a rejected commit message.
---

# Create Commit

Use this workflow when creating or amending commits.

## Goals

- Commit only intended project changes.
- Keep local/ignored environment files out of commits.
- Use the repository's commit message convention.
- When an issue is involved, put `Closes #<nr>` in the commit body/description, not in the subject unless the user explicitly asks.

## Safety checks

1. Inspect the branch and worktree:
   ```bash
   git status --short --branch
   git status --ignored --short
   ```
2. Identify ignored/local-only files and do not stage them unless the user explicitly requests it. Examples:
   - `docker-compose.override.yml`
   - local settings, `.env`, secrets, credentials
3. If there are unrelated or unclear changes, stop and ask what should be included.
4. If checks/tests were recently run, mention them in the final response. Do not claim checks passed unless they actually passed.

## Staging

Stage files explicitly rather than using broad staging by default:

```bash
git add <file1> <file2> ...
git diff --cached --stat
git diff --cached --check
```

If many files are clearly part of the same change, explicit multi-file `git add` is fine. Avoid `git add .` when ignored/local files or unrelated changes are present.

## Commit message convention

Use Conventional Commits unless the repository clearly uses a different convention:

```text
<type>(<scope>): <subject>

<body>
```

Allowed types commonly accepted in this repository:

- `feat`
- `fix`
- `docs`
- `style`
- `refactor`
- `test`
- `chore`

Examples:

```bash
git commit -m "feat(companies): add TV rental to registrations" -m "Closes #1284"
```

```bash
git commit -m "fix(companies): skip TV rental invoice without Orientation Days" -m "Closes #1284"
```

Rules learned:

- The commit subject must match the repository commit hook pattern, e.g. `feat(scope): subject`.
- If the change closes a GitLab issue, include `Closes #<nr>` in the commit body/description.
- Keep the subject concise and reusable as the MR title.
- If a push is rejected because the message does not match the hook, amend the commit message and push again.

## Amending

If the commit already exists locally and needs a message/body fix:

```bash
git commit --amend -m "feat(scope): subject" -m "Closes #<nr>"
```

If it was already pushed, use safe force push only:

```bash
git push --force-with-lease origin <branch>
```

Never use plain `--force` without explicit user approval.

## Final response

Report concisely:

- Commit hash and subject.
- Whether an issue close line was included.
- Whether the branch was pushed, if applicable.
- Checks/tests that were actually run.
- Any files intentionally left uncommitted, especially ignored local config.
