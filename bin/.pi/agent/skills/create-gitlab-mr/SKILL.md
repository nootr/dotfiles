---
name: create-gitlab-mr
description: Push a branch and create or update a GitLab merge request with repository conventions. Use when the user asks to push, create an MR, open a merge request, or fix MR metadata.
---

# Create GitLab MR

Use this workflow when pushing a branch and creating or updating a GitLab merge request.

## Core conventions learned

- The MR title must be exactly the same as the commit subject/title for the branch's main commit.
- The commit body/description should contain `Closes #<nr>` when the MR closes an issue.
- Do not put literal `\n` sequences in the MR description. Use real newlines.
- If amending a pushed commit, push with `--force-with-lease`, never plain `--force` without asking.

## Preconditions

1. Check branch and worktree:
   ```bash
   git status --short --branch
   git status --ignored --short
   git branch --show-current
   ```
2. If there are uncommitted intended changes, create a commit first. If the `create-commit` skill is available, load and follow it.
3. Ensure ignored/local-only files are not accidentally committed. `docker-compose.override.yml` is often intentionally ignored and should remain local unless explicitly requested.
4. Confirm `glab` is available and authenticated:
   ```bash
   command -v glab
   glab auth status
   ```

## Commit metadata

Read the current commit subject and body:

```bash
git log -1 --format=%s
git log -1 --format=%B
```

If an issue number is known and the commit body does not include `Closes #<nr>`, amend before pushing:

```bash
git commit --amend -m "$(git log -1 --format=%s)" -m "Closes #<nr>"
```

After amending an already-pushed branch, push with:

```bash
git push --force-with-lease origin <branch>
```

## Push branch

For a new branch:

```bash
git push -u origin <branch>
```

If the push is rejected by a commit message hook, fix the commit message with the `create-commit` workflow and retry.

## Create MR

Use the current commit subject as the MR title:

```bash
MR_TITLE="$(git log -1 --format=%s)"
```

Write the description to a temp file or heredoc so it contains real newlines:

```bash
cat > /tmp/mr-description.md <<'EOF'
Closes #<nr>

## Summary
- ...

## Verification
- `...`
EOF
```

This `glab` version may not support `--description-file`. Pass the file content via command substitution:

```bash
glab mr create \
  --source-branch <branch> \
  --target-branch <target-branch> \
  --title "$MR_TITLE" \
  --description "$(cat /tmp/mr-description.md)"
```

If an MR already exists, update it instead:

```bash
glab mr update <iid> \
  --title "$MR_TITLE" \
  --description "$(cat /tmp/mr-description.md)"
```

## Fixing an MR with literal `\n`

If the MR description shows literal `\n` instead of line breaks:

```bash
cat > /tmp/mr-description.md <<'EOF'
Closes #<nr>

## Summary
- ...

## Verification
- ...
EOF

glab mr update <iid> --description "$(cat /tmp/mr-description.md)"
```

## Final response

Report concisely:

- Branch pushed.
- Commit hash and subject.
- MR URL.
- MR title.
- Whether `Closes #<nr>` is present in the commit body and/or MR description.
- Checks/tests that were actually run.
