# Clean Merged and Stale Local Branches

Audit local git branches and offer to delete those that are safe to remove.

## Steps

1. Run `git fetch --prune` to sync remote state and remove stale remote-tracking refs.

2. Find **gone branches** — local branches whose upstream has been deleted remotely:
   ```
   git branch -vv | grep ': gone]'
   ```

3. Find **merged branches** — local branches fully merged into the current branch (exclude `main`, `master`, `develop`, and the current branch itself):
   ```
   git branch --merged | grep -vE '^\*|^(\s+)(main|master|develop)$'
   ```

4. Deduplicate the two lists into a combined candidate list.

5. For **gone branches**: present the list and ask me "Delete all gone branches? (yes / no / pick)". If I say "pick", show them one by one and ask yes/no for each.

6. For **merged branches** that weren't already in the gone list: present the list and ask "Delete all merged branches? (yes / no / pick)". Same pick flow if I say "pick".

7. For any remaining local branches not in either category, identify ones whose last commit is older than 30 days:
   ```
   git for-each-ref --sort=committerdate refs/heads/ --format='%(refname:short) %(committerdate:relative)'
   ```
   Present these as **stale branches** (last commit > 30 days ago, excluding main/master/develop and current branch) and ask "Any of these stale branches should be removed? (yes / no / pick)".

8. Delete confirmed branches with `git branch -d` (safe delete). If `-d` fails because the branch is not fully merged, warn me and ask if I want to force-delete with `-D`.

9. Print a summary of what was deleted and what was kept.

Always skip: `main`, `master`, `develop`, and the currently checked-out branch.
