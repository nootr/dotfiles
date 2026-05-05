---
name: rebase-gitlab-mr
description: Rebase a GitLab merge request branch onto another branch safely, using the MR's squash setting and commit count to determine the commit range. Use when the user asks to rebase an MR, says an MR must be rebased onto a target branch, or provides a GitLab MR URL and target branch.
---

# Rebase GitLab MR

Follow this workflow when rebasing a GitLab merge request branch onto a target branch.

## Core rule

The number of commits to rebase depends on whether the MR has squash commits enabled:

- **`squash: false`** (collection branches — every commit on the source branch should be preserved): the MR commit count equals the GitLab `number_of_commits` field. Title matching does **not** apply.
- **`squash: true`**: the first commit of the MR range has the same title as the MR. Walk commit history in reverse to find that commit, then count from there to `HEAD`.

Use `glab` to read MR metadata (`title`, `squash`, `number_of_commits`), pull the MR branch, determine the commit count according to the rule above, then rebase exactly that range with:

```bash
git rebase --onto origin/<target-branch> HEAD~<commit-count>
```

Do **not** default to a plain `git rebase origin/<target-branch>` for MR rebases, because the MR may not be based directly on the target branch (stacked MRs).

## Inputs to identify

- MR URL or MR number.
- Source branch of the MR.
- Target/base branch to rebase onto. If the user explicitly names a target branch, that wins over the MR target branch.
- MR title.
- Whether `squash` is enabled.
- `number_of_commits` (used directly when squash is off).

## Get MR metadata with glab

Use `glab api` so the squash setting and commit count are included:

```bash
glab api "projects/<group%2Fproject>/merge_requests/<mr-iid>" \
  | jq '{title, source_branch, target_branch, squash, number_of_commits}'
```

If `glab` is unavailable or unauthenticated, stop and ask the user how to proceed.

## Safety checks and mandatory first pull

ALWAYS pull first. Before inspecting commit counts or rebasing, the first git operation after identifying MR metadata must be to check out the MR source branch and pull it.

1. Check current branch and worktree:
   ```bash
   git status --short --branch
   ```
2. If there are uncommitted changes, stop and ask the user whether to stash, commit, or abort.
3. Fetch the MR source branch only, so it can be checked out:
   ```bash
   git fetch origin <source-branch>
   ```
4. Check out the MR source branch:
   ```bash
   git checkout <source-branch> || git checkout -b <source-branch> origin/<source-branch>
   ```
5. MANDATORY: pull the MR branch fast-forward only. This must happen before commit inspection, target fetch/rebase, or any other branch manipulation:
   ```bash
   git pull --ff-only
   ```
6. Fetch the target branch after the MR branch has been pulled:
   ```bash
   git fetch origin <target-branch>
   ```
7. Confirm the worktree is clean:
   ```bash
   git status --short --branch
   ```

## Determine the MR commit count

The strategy depends on `squash`.

### Case A — `squash: false`

Use the GitLab `number_of_commits` field directly as the commit count. Title matching does not apply: the first commit of the MR may have any title.

### Case B — `squash: true`

The first commit of the MR range has the same title as the MR.

1. Inspect commit titles on the MR branch:
   ```bash
   git log --format=%s
   ```
2. Find the oldest commit on the source branch whose title equals the MR title. This is the first commit of the MR range.
3. Count commits from that commit through `HEAD` inclusive:
   ```bash
   git rev-list --count <first-mr-commit>^..HEAD
   ```
4. If no commit on the source branch matches the MR title, stop and report. The MR title may have been edited after creation, or the squash setting may be inconsistent. Do not guess.

### Verify against user input

If the user gave an expected commit count, compare it with the computed count. If they differ, report the mismatch and ask before continuing.

## Rebase exactly the MR range

Run:

```bash
git rebase --onto origin/<target-branch> HEAD~<commit-count>
```

This moves only the MR commits onto the requested target branch.

## Conflict handling: always report first

When conflicts occur, do **not** silently resolve and continue. For each conflict round:

1. Find conflicted files:
   ```bash
   git status --short
   rg -n "<<<<<<<|>>>>>>>" <file>
   ```
2. Read the conflicted areas with `read`, not `cat`/`sed`.
3. Prepare a concise conflict report for the user:
   - conflicted file(s)
   - what changed on the target side
   - what changed on the MR side
   - your proposed resolution
4. Ask the user to approve the proposal or give different instructions.
5. Only after approval, edit the files, remove conflict markers, stage resolved files:
   ```bash
   git add <file>
   ```
6. Continue without opening an editor:
   ```bash
   GIT_EDITOR=true git rebase --continue
   ```

If a commit becomes empty, inspect why and ask before `git rebase --skip`, unless it is obviously already present upstream and the user has pre-approved skipping.

Keep a concise note of every conflicted file and final resolution for the final response.

## Verify after rebase

Run:

```bash
git status --short --branch
git rev-list --count origin/<target-branch>..HEAD
git rev-list --count HEAD..origin/<target-branch>
git log --oneline --decorate --graph --left-right --cherry-pick origin/<target-branch>...HEAD | head -80
```

Expected result:

- Source branch is ahead of target by the computed MR commit count.
- Source branch is behind target by `0`.
- Worktree is clean.

## Push

After all conflicts are resolved and verification looks right, push with the safe force option:

```bash
git push --force-with-lease origin <source-branch>
```

If `--force-with-lease` fails, do not use plain `--force` without asking the user.

## Final response

Report concisely:

- MR/source branch rebased onto which target branch.
- MR title and computed commit count.
- Whether it was pushed.
- Ahead/behind verification counts.
- Conflicted files and short resolution summary, if there were conflicts.
- Tests were not run unless you actually ran them.
