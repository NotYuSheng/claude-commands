Review open PR comments, address valid ones, reply to each thread, and resolve conversations.

## Inputs

- `$ARGUMENTS` — PR number (optional). If omitted, detect the current branch's open PR automatically.

## Procedure

### Step 1 — Identify the PR

If `$ARGUMENTS` is provided, use that PR number. Otherwise detect it:

```bash
gh pr view --json number,url,headRefName,baseRefName
```

Capture the PR number, head branch, and base branch.

### Step 2 — Fetch all review comments (inline threads)

```bash
gh api repos/{owner}/{repo}/pulls/<pr_number>/comments \
  --paginate \
  --jq '[.[] | {id, in_reply_to_id, path, line, body, user: .user.login, created_at}]'
```

Group comments into threads by `in_reply_to_id` (root comments have no `in_reply_to_id`). Only process **root** threads — replies are context.

Also fetch issue-level (PR-level) comments:

```bash
gh api repos/{owner}/{repo}/issues/<pr_number>/comments \
  --paginate \
  --jq '[.[] | {id, body, user: .user.login, created_at}]'
```

### Step 3 — Fetch open review threads (for resolve status)

```bash
gh api graphql -f query='
{
  repository(owner: "{owner}", name: "{repo}") {
    pullRequest(number: <pr_number>) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          path
          line
          comments(first: 10) {
            nodes {
              id
              body
              author { login }
              createdAt
            }
          }
        }
      }
    }
  }
}'
```

Keep only threads where `isResolved: false`.

### Step 4 — Read the relevant source files

For each unresolved inline thread, read the file at the path referenced using the Read tool. Focus on the lines surrounding the comment's `line` number (±20 lines of context). This gives you the actual code to reason about.

### Step 5 — Evaluate each comment

For each unresolved thread, decide:

- **Valid** — the comment identifies a real bug, improvement, or missing piece that should be addressed in this PR.
- **Acknowledged / out of scope** — the concern is noted but intentionally deferred, by design, or outside the PR scope.
- **Question** — the reviewer is asking a question that needs a direct answer, not a code change.
- **Disagree** — you have a clear technical reason the current approach is correct.

### Step 6 — Address valid comments

For comments judged **Valid**: make the necessary code change using the Edit tool. Stage the change mentally — you will commit after all edits are done.

If multiple comments affect the same file, batch the edits.

### Step 7 — Reply to each thread

For every thread (valid, acknowledged, question, or disagree), post a reply explaining what was done or why. Keep replies concise and professional.

For **inline threads** (code review comments), reply via:

```bash
gh api repos/{owner}/{repo}/pulls/<pr_number>/comments \
  --method POST \
  -f body="<reply>" \
  -F in_reply_to=<root_comment_id>
```

For **PR-level comments**, reply via:

```bash
gh api repos/{owner}/{repo}/issues/<pr_number>/comments \
  --method POST \
  -f body="<reply>"
```

### Step 8 — Resolve threads

After replying, resolve each thread using the GraphQL mutation:

```bash
gh api graphql -f query='
mutation {
  resolveReviewThread(input: { threadId: "<thread_node_id>" }) {
    thread { isResolved }
  }
}'
```

Resolve all threads you replied to — both addressed ones and acknowledged/answered ones.

### Step 9 — Commit and push (if changes were made)

If any code edits were made in Step 6:

Derive a concise commit description (kebab-case, max 60 chars) summarising what was actually fixed — e.g. `fix/null-check-on-user-input` or `fix/missing-error-handling-in-parser`. Do not use a generic description like "address pr review comments".

```bash
git add <changed files>
git commit -m "fix/<derived-description>"
git push
```

### Step 10 — Report

Print a summary table:

| Thread | File:Line | Status | Action taken |
|--------|-----------|--------|--------------|
| ...    | ...       | Fixed / Acknowledged / Answered / Disagreed | ... |

Then print the total counts: N fixed, N acknowledged, N answered, N disagreed.
