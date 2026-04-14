Create a GitHub issue, branch, commit, push, and open a PR — all wired into the KMS project board.

## Inputs — infer everything from context, ask nothing

Do NOT ask the user for any inputs. Derive all values from the conversation context, staged changes, and git state:

- **Title** — infer from the task description or changed files
- **Description** — summarise what was done and why
- **Labels** — infer from change type (e.g. `documentation`, `feature`, `bug`, `infrastructure`)
- **Target date** — use today's date (it's already done)
- **Priority** — infer from impact: `P2` for docs/chore, `P1` for features, `P0` for blockers
- **Size** — infer from files changed: 1-2 files = `XS`, 3-5 = `S`, 6-10 = `M`, 10+ = `L`
- **Estimate** (Fibonacci: 1, 2, 3, 5, 8, 13):
  - **1 pt** — < 2h, 1 file, trivial change
  - **2-3 pts** — 2-4h, 2-3 files, known pattern
  - **5 pts** — 1-2 days, multiple files/components
  - **8 pts** — 3-5 days, cross-cutting, needs design
  - **13+ pts** — 1+ week, must be broken down first

Report all chosen values in the Step 5 summary.

## Procedure

### Step 1 — Find the latest active milestone

```bash
gh api repos/o6-webwork/KMS/milestones --jq 'sort_by(.due_on) | map(select(.state=="open")) | last | .number'
```

Use the returned milestone number when creating the issue.

### Step 2 — Create the GitHub issue

```bash
gh issue create \
  --title "<title>" \
  --body "<description>" \
  --milestone <milestone_number> \
  --label "<labels>"
```

Capture the issue number from the output.

### Step 3 — Add the issue to the KMS project board and set fields

Add to project #8 (KMS):

```bash
ITEM_ID=$(gh project item-add 8 --owner o6-webwork --url <issue_url> --format json | jq -r '.id')
```

Then set each project field. Use the field IDs and option IDs below:

**Status** — field `PVTSSF_lADODDJ7084BR9pqzg_osJQ`:
| Value            | Option ID    |
|------------------|--------------|
| Backlog          | f75ad846     |
| Blocked          | 51ccef20     |
| In progress      | 47fc9ee4     |
| Ready for Review | df73e18b     |
| Done             | 98236657     |

**Priority** — field `PVTSSF_lADODDJ7084BR9pqzg_osL0`:
| Value | Option ID    |
|-------|--------------|
| P0    | 79628723     |
| P1    | 0a877460     |
| P2    | da944a9c     |

**Size** — field `PVTSSF_lADODDJ7084BR9pqzg_osL4`:
| Value | Option ID    |
|-------|--------------|
| XS    | 6c6483d2     |
| S     | f784b110     |
| M     | 7515a9f1     |
| L     | 817d0097     |
| XL    | db339eb2     |

Set the fields using `gh project item-edit`:

```bash
# Status → In progress
gh project item-edit --project-id PVT_kwDODDJ7084BR9pq --id $ITEM_ID --field-id PVTSSF_lADODDJ7084BR9pqzg_osJQ --single-select-option-id <status_option_id>

# Priority
gh project item-edit --project-id PVT_kwDODDJ7084BR9pq --id $ITEM_ID --field-id PVTSSF_lADODDJ7084BR9pqzg_osL0 --single-select-option-id <priority_option_id>

# Size
gh project item-edit --project-id PVT_kwDODDJ7084BR9pq --id $ITEM_ID --field-id PVTSSF_lADODDJ7084BR9pqzg_osL4 --single-select-option-id <size_option_id>

# Estimate (number field)
gh project item-edit --project-id PVT_kwDODDJ7084BR9pq --id $ITEM_ID --field-id PVTF_lADODDJ7084BR9pqzg_osL8 --number <estimate>

# Start date — always today's date (YYYY-MM-DD)
gh project item-edit --project-id PVT_kwDODDJ7084BR9pq --id $ITEM_ID --field-id PVTF_lADODDJ7084BR9pqzg_osMA --date <today>

# Target date
gh project item-edit --project-id PVT_kwDODDJ7084BR9pq --id $ITEM_ID --field-id PVTF_lADODDJ7084BR9pqzg_osME --date <target_date>
```


### Step 4 — Create branch, commit, push, and open PR

```bash
# Derive branch name from type and title (kebab-case), e.g. feature/trino-rbac-governance
# Type is inferred from the issue labels or title prefix: feature/, fix/, chore/, docs/, etc.
# Do NOT prefix with the issue number.
BRANCH="<type>/<kebab-title>"
git checkout -b "$BRANCH"
git push -u origin "$BRANCH"
```

Stage any uncommitted changes. If there are changes to commit, commit them. Then create the PR:

```bash
gh pr create \
  --title "<title>" \
  --body "Closes #<issue_number>

## Summary
<description>

## Test plan
- [ ] TODO

🤖 Generated with [Claude Code](https://claude.com/claude-code)" \
  --milestone <milestone_number>
```

### Step 5 — Report

Print a summary with:
- Issue URL
- PR URL
- Branch name
- Project board fields that were set
